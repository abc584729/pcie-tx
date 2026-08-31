# =====================================================================
# vio.tcl - TX bring-up script (Vivado 2020.2 Hardware Manager)
#
# Configures hw_vio u_vio_tx to enable the transmit chain (tx_top):
#   probe_out0 = tx_rstn              (1 bit)
#   probe_out1 = tx_en                (1 bit)
#   probe_out2 = dds_rstn             (1 bit)
#   probe_out3 = dds_pinc_bpsk        (16 bit)
#   probe_out4 = dds_pinc_qpsk        (16 bit)
#   probe_out5 = dds_poff_bpsk        (128 bit)
#   probe_out6 = dds_poff_qpsk        (128 bit)
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
# Note: hold the chain in reset while programming pinc/poff, then
#       release resets and finally assert tx_en.
# =====================================================================

set VIO_NAME  u_vio_tx
set LTX       E:/yyy/TSF_simulator_6.0/bit/top.ltx
set PINC_BPSK 0x8E39
set PINC_QPSK 0x1C72
set POFF_BPSK 0x838E9555A71CB8E4CAABDC72EE390000
set POFF_QPSK 0x071C2AAB4E3971C79555B8E4DC720000

# ---------------------------------------------------------------------
# Main flow (wrapped in a proc to avoid polluting global variables)
proc vio_tx_setup {} {
    global VIO_NAME LTX PINC_BPSK PINC_QPSK POFF_BPSK POFF_QPSK

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

    set vio [lindex [get_hw_vios -quiet -filter "CELL_NAME =~ *$VIO_NAME*"] 0]
    if {$vio eq ""} {
        set vio [lindex [get_hw_vios -quiet $VIO_NAME] 0]
    }
    if {$vio eq ""} {
        set vio [lindex [get_hw_vios -quiet] 0]
        puts "WARNING: $VIO_NAME not found, falling back to: $vio"
    }
    if {$vio eq ""} {
        error "No VIO core found, check the bit/ltx (top.ltx)"
    }

    # Read the mmcm lock status from probe_in0 before touching outputs
    refresh_hw_vio $vio
    set locked [get_property PROBE_IN0.VALUE $vio]
    puts "mmcm_locked (probe_in0) = $locked"
    if {$locked ne "1"} {
        puts "WARNING: MMCM not locked, the transmit clock may be absent"
    }

    # Hold the whole chain in reset while programming the parameters
    set_property PROBE_OUT0.VALUE 0 $vio          ;# tx_rstn
    set_property PROBE_OUT1.VALUE 0 $vio          ;# tx_en
    set_property PROBE_OUT2.VALUE 0 $vio          ;# dds_rstn
    set_property PROBE_OUT3.VALUE $PINC_BPSK $vio
    set_property PROBE_OUT4.VALUE $PINC_QPSK $vio
    set_property PROBE_OUT5.VALUE $POFF_BPSK $vio
    set_property PROBE_OUT6.VALUE $POFF_QPSK $vio
    after 100

    # Release the DDS and tx resets, then start transmission
    set_property PROBE_OUT2.VALUE 1 $vio          ;# dds_rstn
    set_property PROBE_OUT0.VALUE 1 $vio          ;# tx_rstn
    after 100
    set_property PROBE_OUT1.VALUE 1 $vio          ;# tx_en

    puts "---------------------------------------------"
    puts "u_vio_tx configured:"
    puts "  tx_rstn    = [get_property PROBE_OUT0.VALUE $vio]"
    puts "  tx_en      = [get_property PROBE_OUT1.VALUE $vio]"
    puts "  dds_rstn   = [get_property PROBE_OUT2.VALUE $vio]"
    puts "  pinc_bpsk  = [get_property PROBE_OUT3.VALUE $vio]"
    puts "  pinc_qpsk  = [get_property PROBE_OUT4.VALUE $vio]"
    puts "  poff_bpsk  = [get_property PROBE_OUT5.VALUE $vio]"
    puts "  poff_qpsk  = [get_property PROBE_OUT6.VALUE $vio]"
    puts "Transmit chain enabled, ready to run ila.tcl"
}

if {[info commands get_hw_vios] ne ""} {
    vio_tx_setup
}
