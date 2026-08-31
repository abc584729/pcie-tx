# =====================================================================
# ila.tcl - TX data acquisition script (Vivado 2020.2 Hardware Manager)
#
# Captures u_ila_tx (probe0 = i[127:0], probe1 = q[127:0], clocked at
# clk_180m, depth 1024) N times, converts the exported hex CSV into
# result.csv for matlab/vivado_analysis.m.
# result.csv format: one 128-bit binary string per line, I/Q lines
# interleaved, no header.
#
# Usage:
#   1. Hardware Manager -> Open Target -> Auto Connect
#   2. Bring up the transmit chain first: source vio.tcl
#      (it sets tx_rstn/tx_en/dds_rstn = 1, pinc_bpsk = 0x8E39 for
#       fc = 100 MHz, pinc_qpsk = 0x1C72 for fc = 200 MHz)
#   3. Tcl Console: source ila.tcl
#
# Note: result.csv is overwritten on every run.
# =====================================================================

set N        20
set ILA_NAME u_ila_tx
set OUT_FILE E:/yyy/TSF_simulator_6.0/pcie-tx-main/matlab/result.csv
set TMP_CSV  ./ila_tx_raw.csv
set LTX      E:/yyy/TSF_simulator_6.0/bit/top.ltx

# ---------------------------------------------------------------------
# hex string -> binary string (MSB first), zero-padded to width bits
proc hex2bin {hex width} {
    array set nib {0 0000 1 0001 2 0010 3 0011 4 0100 5 0101
                   6 0110 7 0111 8 1000 9 1001 a 1010 b 1011
                   c 1100 d 1101 e 1110 f 1111}
    set hex [string tolower [string trim $hex]]
    if {![regexp {^[0-9a-f]+$} $hex]} {
        error "hex2bin: invalid hex value \"$hex\""
    }
    set bin ""
    foreach ch [split $hex ""] {
        append bin $nib($ch)
    }
    while {[string length $bin] < $width} {
        set bin "0$bin"
    }
    return [string range $bin end-[expr {$width - 1}] end]
}

# ---------------------------------------------------------------------
# Parse the CSV exported by write_hw_ila_data:
#   line 1 = header, line 2 = radix description, data rows start with
#   the sample index and carry probe values in hex; the last two
#   columns are probe0 (i) and probe1 (q).
# Append "I line\nQ line" binary text to outFile, return the frame count.
proc convert_ila_csv {csvPath outFile} {
    set fh [open $csvPath r]
    set of [open $outFile a]
    fconfigure $of -translation lf
    set rows 0
    while {[gets $fh line] >= 0} {
        set line [string trim $line "\r \t"]
        if {$line eq ""} { continue }
        set fld [split $line ","]
        if {![regexp {^[0-9]+$} [lindex $fld 0]]} { continue }
        if {[llength $fld] < 3} { continue }
        set ihex [lindex $fld end-1]
        set qhex [lindex $fld end]
        if {![regexp {^[0-9a-fA-F]+$} $ihex] || ![regexp {^[0-9a-fA-F]+$} $qhex]} {
            close $fh
            close $of
            error "failed to parse data row: $line"
        }
        puts $of [hex2bin $ihex 128]
        puts $of [hex2bin $qhex 128]
        incr rows
    }
    close $fh
    close $of
    return $rows
}

# ---------------------------------------------------------------------
# Main flow (wrapped in a proc to avoid polluting global variables)
proc ila_tx_capture {} {
    global N ILA_NAME OUT_FILE TMP_CSV LTX

    if {[info commands get_hw_ilas] eq ""} {
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

    if {[llength [get_hw_ilas -quiet]] == 0} {
        puts "No ILA visible, loading probes file: $LTX"
        set_property PROBES.FILE $LTX $dev
        refresh_hw_device $dev
    }

    set ila [lindex [get_hw_ilas -quiet -filter "CELL_NAME =~ *$ILA_NAME*"] 0]
    if {$ila eq ""} {
        set ila [lindex [get_hw_ilas -quiet $ILA_NAME] 0]
    }
    if {$ila eq ""} {
        set ila [lindex [get_hw_ilas -quiet] 0]
        puts "WARNING: $ILA_NAME not found, falling back to: $ila"
    }
    if {$ila eq ""} {
        error "No ILA core found, check the bit/ltx (top.ltx)"
    }
    set depth 1024
    puts "ILA: $ila (depth $depth)"

    set f [open $OUT_FILE w]
    close $f
    set total 0
    for {set n 0} {$n < $N} {incr n} {
        if {[catch {run_hw_ila $ila; wait_on_hw_ila $ila} err]} {
            error "ILA capture failed: $err"
        }
        set data [get_hw_ila_data -of_objects $ila]
        write_hw_ila_data -force -csv_file $TMP_CSV $data
        set rows [convert_ila_csv $TMP_CSV $OUT_FILE]
        incr total $rows
        if {$rows != $depth} {
            puts "WARNING: capture [expr {$n + 1}] got $rows rows, depth is $depth"
        }
        puts "Capture [expr {$n + 1}]/$N done: $rows frames (total $total)"
    }
    file delete -force $TMP_CSV

    puts "---------------------------------------------"
    puts "Acquisition finished: $total frames -> $OUT_FILE"
    puts "[expr {$total * 8}] complex IQ samples, analyze with vivado_analysis.m"
}

if {[info commands get_hw_ilas] ne ""} {
    ila_tx_capture
}
