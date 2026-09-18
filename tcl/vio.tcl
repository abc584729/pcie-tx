# =====================================================================
# vio.tcl - TX bring-up script (Vivado 2020.2 Hardware Manager)
#
# Configures hw_vio u_vio_tx to enable the transmit chain (tx_top):
#   probe_out0 = tx_rstn              (1 bit)
#   probe_out1 = ram_en               (1 bit)   (was tx_en; now the bpsk/qpsk RAM read enable)
#   probe_out2 = dds_rstn             (1 bit)
#   probe_out3 = dds_pinc_bpsk        (16 bit)
#   probe_out4 = dds_pinc_qpsk        (16 bit)
#   probe_out5 = dds_poff_bpsk        (128 bit)
#   probe_out6 = dds_poff_qpsk        (128 bit)
#   probe_out7 = tx_sel_vio_ps        (1 bit)   (1 = PS owns the TX chain, 0 = VIO)
#   probe_out8 = atten_bpsk           (16 bit signed, Q1.14, 0x4000 = 0 dB)
#   probe_out9 = atten_qpsk           (16 bit signed, Q1.14, 0x4000 = 0 dB)
#   probe_out10 = bpsk_en             (1 bit)
#   probe_out11 = qpsk_en             (1 bit)
#
# NOTE: the VIO IP (vio_tx) must be regenerated with 12 probe_outs
#       (probe_out0..11) for this script to work, and probe_out8/9
#       widened to 16 bit for the Q1.14 attenuation coefficients.
#
# Defaults match tb/tb_tx.v:
#   BPSK: fc = 100 MHz, pinc = round(65536*100/180) = 36409 = 0x8E39
#   QPSK: fc = 200 MHz, pinc = (65536*200/180) mod 2^16 = 7282 = 0x1C72
#   poff: per-lane phase offset -k*pinc/8, MSB = earliest sample, so the
#         leading (highest) lanes carry the most advanced phase (the DDS
#         negates the streamed poff internally).
#
# Usage:
#   Hardware Manager -> Open Target -> Auto Connect, then in Tcl
#   Console: source vio.tcl
#
#   By default this hands the transmit chain to the PS (SET_TX_CTRL = ps),
#   which is what the UDP symbol-table upload needs. To drive the chain from
#   this VIO instead (the pre-upload bring-up flow):
#       set SET_TX_CTRL vio ; source vio.tcl
#
# Note: hold the chain in reset while programming pinc/poff, then
#       release resets, assert bpsk/qpsk enable, and finally assert ram_en.
#       Those steps only take effect when SET_TX_CTRL is "vio".
# =====================================================================

# Who drives the transmit chain. ps/top.vhd:4755-4765 muxes every TX control
# signal between this VIO and the PS on probe_out7 (tx_sel_vio_ps):
#
#   "ps"  -> tx_sel_vio_ps = 1: the PS owns tx_rstn/ram_en/freq/atten/enable.
#            This is what tx_start.py (case 135, on top of case 133/134)
#            needs, and the only setting under which an uploaded symbol table
#            is transmitted.
#            probe_out0..6/10/11 below become inert.
#   "vio" -> tx_sel_vio_ps = 0: probe_out0..6/10/11 drive the chain and every
#            value the PS writes is ignored.
#
# The probe powers up at 0, so without writing it the PS path is dead -- and
# the symptom is nasty: an uploaded table lands in the RAM fine (the write
# port bypasses the mux, ps/top.vhd:4781-4786) but nothing is ever sent.
# To get the old VIO-only bring-up back:
#   set SET_TX_CTRL vio ; source vio.tcl
set SET_TX_CTRL ps

set VIO_NAME  u_vio_tx
set LTX       E:/yyy/TSF_simulator_6.0/bit/top.ltx
set PINC_BPSK 0x8E39
set PINC_QPSK 0x1C72
set POFF_BPSK 0x838E9555A71CB8E4CAABDC72EE390000
set POFF_QPSK 0x071C2AAB4E3971C79555B8E4DC720000

# ---------------------------------------------------------------------
# Main flow (wrapped in a proc to avoid polluting global variables)
proc vio_tx_setup {} {
    global VIO_NAME LTX PINC_BPSK PINC_QPSK POFF_BPSK POFF_QPSK SET_TX_CTRL

    if {[info commands get_hw_vios] eq ""} {
        error "Run inside Vivado Hardware Manager with the target connected"
    }

    catch { open_hw_manager }
    if {[llength [get_hw_servers -quiet]] == 0} {
        connect_hw_server
    }

    set devs [get_hw_devices -quiet]
    if {[llength $devs] == 0} {
        error "No JTAG device found, please Open Target -> Auto Connect first"
    }
    set dev ""
    catch { set dev [current_hw_device] }
    if {$dev eq ""} {
        set dev [lindex $devs 0]
        current_hw_device $dev
    }
    puts "Target device: $dev"

    if {[llength [get_hw_vios -quiet]] == 0} {
        puts "No VIO visible, loading probes file: $LTX"
        set_property PROBES.FILE $LTX $dev
        refresh_hw_device $dev
    }

    # Find the intended VIO by exact CELL_NAME first; a fuzzy match can
    # silently pick another VIO (e.g. U_vio_SEL / U_vio_ENABLE_POWER) and
    # later fail with "does not have a [PROBE_IN0.VALUE] property".
    set vios [get_hw_vios -quiet]
    set vio ""
    foreach v $vios {
        if {[get_property CELL_NAME $v] eq $VIO_NAME} { set vio $v; break }
    }
    if {$vio eq ""} {
        # Fallback: case-insensitive / hierarchical name match
        foreach v $vios {
            set cn [get_property CELL_NAME $v]
            if {[string match -nocase "*$VIO_NAME*" $cn]} { set vio $v; break }
        }
    }
    if {$vio eq ""} {
        puts "ERROR: VIO '$VIO_NAME' not found. Available VIO cores:"
        foreach v $vios {
            puts "  [get_property CELL_NAME $v]  ($v)"
        }
        error "No VIO core named $VIO_NAME, check the bit/ltx (top.ltx)"
    }
    puts "VIO: $vio  CELL_NAME=[get_property CELL_NAME $vio]"

    # Read the mmcm lock status from probe_in0 before touching outputs,
    # but only if this core actually has a probe_in0 port.
    set props [list_property $vio]
    if {[lsearch -exact $props "PROBE_IN0.VALUE"] >= 0} {
        refresh_hw_vio $vio
        set locked [get_property PROBE_IN0.VALUE $vio]
        puts "mmcm_locked (probe_in0) = $locked"
        if {$locked ne "1"} {
            puts "WARNING: MMCM not locked, the transmit clock may be absent"
        }
    } else {
        puts "WARNING: [get_property CELL_NAME $vio] has no probe_in0 port; skipping mmcm_locked check"
    }

    # Sanity check: this core must expose probe_out0..11 (12 outputs)
    if {[lsearch -exact $props "PROBE_OUT11.VALUE"] < 0} {
        error "VIO '[get_property CELL_NAME $vio]' does not have PROBE_OUT11 (expected 12 probe_outs); regenerate vio_tx with probe_out10/11 for bpsk_en/qpsk_en"
    }

    # Hold the whole chain in reset while programming the parameters
    set_property PROBE_OUT0.VALUE 0 $vio          ;# tx_rstn
    set_property PROBE_OUT1.VALUE 0 $vio          ;# ram_en
    set_property PROBE_OUT2.VALUE 0 $vio          ;# dds_rstn
    set_property PROBE_OUT3.VALUE $PINC_BPSK $vio
    set_property PROBE_OUT4.VALUE $PINC_QPSK $vio
    set_property PROBE_OUT5.VALUE $POFF_BPSK $vio
    set_property PROBE_OUT6.VALUE $POFF_QPSK $vio
    set_property PROBE_OUT10.VALUE 1 $vio         ;# bpsk_en
    set_property PROBE_OUT11.VALUE 1 $vio         ;# qpsk_en

    # Hand the chain to the PS or keep it here -- see the SET_TX_CTRL note above.
    if {$SET_TX_CTRL eq "ps"} {
        set_property PROBE_OUT7.VALUE 1 $vio      ;# tx_sel_vio_ps -> PS
    } elseif {$SET_TX_CTRL eq "vio"} {
        set_property PROBE_OUT7.VALUE 0 $vio      ;# tx_sel_vio_ps -> VIO
    } else {
        error "SET_TX_CTRL must be \"ps\" or \"vio\", got \"$SET_TX_CTRL\""
    }
    after 100

    # Release the DDS and tx resets, then start transmission
    set_property PROBE_OUT2.VALUE 1 $vio          ;# dds_rstn
    set_property PROBE_OUT0.VALUE 1 $vio          ;# tx_rstn
    after 100
    set_property PROBE_OUT1.VALUE 1 $vio          ;# ram_en

    puts "---------------------------------------------"
    puts "u_vio_tx configured:"
    puts "  tx_rstn    = [get_property PROBE_OUT0.VALUE $vio]"
    puts "  ram_en     = [get_property PROBE_OUT1.VALUE $vio]"
    puts "  dds_rstn   = [get_property PROBE_OUT2.VALUE $vio]"
    puts "  pinc_bpsk  = [get_property PROBE_OUT3.VALUE $vio]"
    puts "  pinc_qpsk  = [get_property PROBE_OUT4.VALUE $vio]"
    puts "  poff_bpsk  = [get_property PROBE_OUT5.VALUE $vio]"
    puts "  poff_qpsk  = [get_property PROBE_OUT6.VALUE $vio]"
    puts "  bpsk_en    = [get_property PROBE_OUT10.VALUE $vio]"
    puts "  qpsk_en    = [get_property PROBE_OUT11.VALUE $vio]"
    puts "  tx_sel_vio_ps = [get_property PROBE_OUT7.VALUE $vio]  (SET_TX_CTRL=$SET_TX_CTRL)"

    if {$SET_TX_CTRL eq "vio"} {
        puts "Transmit chain enabled from VIO, ready to run ila.tcl"
        puts "NOTE: tx_sel_vio_ps = 0, so the PS is ignored -- tx_configure.py"
        puts "      and tx_start.py (case 133/135) will not control the chain in"
        puts "      this mode."
    } else {
        puts "tx_sel_vio_ps = 1: the PS owns the transmit chain."
        puts "The probe_out0..6/10/11 values above are inert in this mode."
        puts "Next: python tx_configure.py --bpsk-freq 100 --qpsk-freq 200"
        puts "      python tx_ram_configure.py --table <file> --table-sel bpsk"
        puts "      python tx_start.py --single 0   (starts transmission; tx_start()"
        puts "      runs on the board)"
    }
}

if {[info commands get_hw_vios] ne ""} {
    vio_tx_setup
}
