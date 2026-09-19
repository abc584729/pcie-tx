#!/usr/bin/env python3
"""
tx_start.py
Send the UDP "start transmission" command packet to a node, packed according
to case 135 of the //20260902 edit in adhocSoft.c.

This is the *start* half of the old send_tx_init.py: it carries the BPSK burst
parameters (single shot / cyclic, how many symbols to send, and where in the
timebase to start) and then calls tx_start() on the board, which pushes the
whole configuration to hardware and starts transmitting.

Run it after tx_configure.py (frequency / attenuation / enable / rate) and
after tx_ram_configure.py (the symbol RAM). Both of those keep their values;
this script is what actually makes RF come out.

case 135 payload layout (UDP payload == raw pBuf; the Ethernet control
socket has no frame header and no CRC):

    offset   field                      type
    ---------------------------------------------
    0        command = 135              u8
    1        bpsk_single_shot           u8 (0 = cyclic, 1 = single shot)
    2..9     bpsk_size_kb               double (8B, little-endian IEEE-754)
                                       size of the symbol-table data file, in
                                       kB (1024-based, like the K/M/G suffixes
                                       of gen_symbol_table.py)
    10..17   bpsk_time_sel              double (8B, little-endian IEEE-754)
                                       0 <= x < 1024, unit = symbols

    Total length = 18 bytes.

    bpsk_size_kb is the size of the .bin that was uploaded with case 134, so
    "send exactly what I just uploaded" needs no arithmetic on the host side.
    adhocSoft.c converts it to a symbol count: BPSK carries 1 bit per symbol,
    so bits = kB * 1024 * 8 = kB * 8192. The full 512 kB table is therefore
    4194304 bits = 4194304 symbols, which is exactly one pass over the RAM.
    The 23-bit symbol counter caps it at ~1024 kB.

    That count is a *turn*: cyclic mode sends it and then jumps back to symbol
    0 for the next turn, forever, so --size sets how much of the table each
    lap covers. Single shot sends one turn and goes silent. A size larger than
    the table makes the RAM repeat inside a turn (the read pointer wraps at
    4194304 while the count keeps going).

    What --size 0 means depends on the mode: single shot sends nothing (the
    register default is 0, and an obvious empty burst beats forgetting the
    field and blasting a whole table), cyclic sends the whole table -- which
    is the power-up default and keeps the old always-full-table behaviour.

    The ARM (Zynq) is little-endian and the C side copies the double with
    memcpy(&double, &pBuf[off], 8), so the double is packed with '<d'.

    bpsk_time_sel is where in the 1024-symbol timebase the BPSK read gate
    opens, which is how you place the start of a burst at a known, repeatable
    position on a scope. The timebase is 1024 symbols long (450k: 400*1024 clk
    = 2.276 ms; 400k: 450*1024 = 2.56 ms) and is driven by the same divider
    pulse that reads the table, so the pulse that matches bpsk_time_sel is
    spent opening the gate and reads nothing: the first symbol actually
    transmitted sits at timebase position bpsk_time_sel + 1. 0 = open it on
    the very first pulse after reset (= start as soon as possible). Only the
    PS path uses it -- in VIO mode the top level ties it to 0.

    It is a *fractional* symbol position, so the calibration is no longer
    stuck on the 1/Rs grid. The board splits it into two hardware registers
    (0x718 and 0x71C) using the current rate, because a symbol is 400 clocks
    at 450k but 450 clocks at 400k:

        time_sel  = floor(x)                        (0x718, 0..1023)
        clock_sel = round((x - floor(x)) * count_max)  (0x71C)

    with count_max = 400 (450k) or 450 (400k). So the fractional part always
    means the same *fraction of a symbol*, i.e. the same real time at either
    rate: --tsel 500.25 is a quarter symbol into symbol 500. The conversion
    happens in case 135 and reads tx_rate_sel there, so changing the rate
    afterwards needs another case 135 to move the sub-symbol offset with it.

    Resolution caveat: the read gate itself is now clock-accurate, but the
    sample still has to cross upsamping_450k / 400k, whose first
    zero_interpolator latches the bit and emits it on the next slot of its own
    free-running /50 counter. The RF envelope therefore only moves in 50-clock
    steps -- 1/8 of a symbol, about 278 ns at 180 MHz -- so x is quantised
    onto that grid even though finer values are accepted.

    It is written inside the tx_start() reset window (reset is pulsed at step
    5, the register is written at step 4), so the timebase counter is held at
    0 while it lands and the value is always ahead of the counter: no waiting
    for the next lap, and the burst comes up at the calibrated position
    without any extra command. The cost of the same reset is that the
    reference timebase itself restarts, so time_sel is only meaningful
    relative to the start of *this* burst -- the old live 0x702=0 -> 0x718 ->
    0x702=1 trick that changed it mid-flight without resetting is gone.

    Running this again re-triggers the burst: tx_start() pulses TX_REG_RESET,
    which is what clears the read pointer, the symbol counter, `done` and the
    timebase counter -- a finished single-shot burst cannot restart without it.

    Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
    listening port, see adhocSoft.c).

Examples:
    cd /d
    python tx_start.py --single 1 --size 256        # the 256 kB file just uploaded
    python tx_start.py --single 1 --size full       # whole 512 kB table
    python tx_start.py --single 1 --size 1.953125   # a 2000-byte file
    python tx_start.py --single 0                   # cyclic, whole table per turn
    python tx_start.py --tsel 500                   # open the gate at count 500
    python tx_start.py --tsel 500.25                # a quarter symbol later
    python tx_start.py --single 1 --size 256 --tsel 500 --rate 0
    python tx_start.py --single 0 --dry-run
"""

import argparse
import socket
import struct

CMD_TX_START = 135

OFF_SINGLE_SHOT = 1
OFF_SIZE_KB = 2
OFF_TIME_SEL = 10

PKT_LEN = 18            # cmd + single_shot + size_kb + time_sel

# time_sel: 1024 symbols per timebase frame, integer part 0..1023 and a
# fractional part that the board turns into a sub-symbol clock offset.
TIME_SEL_MAX = 1023

# clocks per symbol in bpsk_ram: COUNT_MAX_450K / COUNT_MAX_400K
CLK_PER_SYM_450K = 400
CLK_PER_SYM_400K = 450

# The symbol table is 262144 x 16 bit = 512 kB of file = 2^22 bit = 2^22 symbols
TABLE_KB = 512.0        # one full pass over the BPSK table
BITS_PER_KB = 1024 * 8  # BPSK: 1 bit per symbol, so bits == symbols
SIZE_KB_MAX = ((1 << 23) - 1) / float(BITS_PER_KB)   # 23-bit counter, ~1024 kB

DEF_SINGLE = 1         # 1 = single shot (this command exists to fire a burst)
DEF_SIZE_KB = 0.0      # 0 = send nothing in single-shot mode
DEF_TIME_SEL = 0.0     # 0 = open the read gate on the first pulse (start ASAP)


def split_time_sel(tsel, rate):
    """Mirror of adhocSoft.c case 135: symbol position -> (time_sel, clock_sel)."""
    count_max = CLK_PER_SYM_400K if rate == 1 else CLK_PER_SYM_450K
    ts = int(tsel)                                   # truncate, like the C cast
    cs = int((tsel - ts) * count_max + 0.5)          # round to the nearest clock
    if ts > TIME_SEL_MAX:
        ts = TIME_SEL_MAX
    if cs > count_max:                               # the fraction rounded up
        cs = count_max
    return ts, cs


def parse_size_kb(text):
    """'full' -> the whole table; '256K'/'1M' -> 1024-based; else a plain float."""
    t = str(text).strip().lower()
    if t in ('full', 'all'):
        return TABLE_KB
    mult = 1.0
    if t.endswith('k'):
        t, mult = t[:-1], 1.0
    elif t.endswith('m'):
        t, mult = t[:-1], 1024.0
    try:
        kb = float(t) * mult
    except ValueError:
        raise SystemExit('bad --size %r: use kB (256, 1.5, 256K) or "full"' % text)
    if kb < 0:
        raise SystemExit('--size %g kB is negative' % kb)
    if kb > SIZE_KB_MAX:
        raise SystemExit('--size %g kB too big: the 23-bit symbol counter caps it '
                         'at %g kB' % (kb, SIZE_KB_MAX))
    return kb


def build_packet(single_shot, size_kb, time_sel):
    """Pack the payload per the case 135 layout; return bytes(18)."""
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_TX_START
    buf[OFF_SINGLE_SHOT] = int(single_shot) & 0x1
    struct.pack_into('<d', buf, OFF_SIZE_KB, float(size_kb))
    struct.pack_into('<d', buf, OFF_TIME_SEL, float(time_sel))
    return bytes(buf)


def hex_dump(data):
    out = []
    for i in range(0, len(data), 16):
        chunk = data[i:i + 16]
        hexs = ' '.join('%02X' % b for b in chunk)
        ascii_ = ''.join(chr(b) if 0x20 <= b < 0x7F else '.' for b in chunk)
        out.append('%04X  %-47s  |%s|' % (i, hexs, ascii_))
    return '\n'.join(out)


def main():
    ap = argparse.ArgumentParser(
        description='Send the //20260902 case 135 start command: BPSK burst '
                    'length/mode, then tx_start() on the board.')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--rate', type=int, choices=(0, 1),
                    help='symbol rate of the *current* board setup (0 = bpsk 450k, '
                         '1 = bpsk 400k); the packet does not carry it -- set it with '
                         'tx_configure.py --rate. It only affects the printout here, '
                         'but the board uses its own tx_rate_sel to turn the fractional '
                         'part of --tsel into a sub-symbol clock offset, so keep the two '
                         'in step or the offset means a different real time')
    ap.add_argument('--single', type=int, default=DEF_SINGLE, choices=(0, 1),
                    help='BPSK mode: 0 = cyclic, 1 = single shot (default %d)' % DEF_SINGLE)
    ap.add_argument('--size', default=str(DEF_SIZE_KB),
                    help='size of the uploaded symbol-table file, in kB (1024-based, '
                         'K/M suffix ok) or "full" for the whole %g kB table; '
                         'default %g' % (TABLE_KB, DEF_SIZE_KB))
    ap.add_argument('--tsel', type=float, default=DEF_TIME_SEL,
                    help='BPSK start position in the 1024-symbol timebase, 0 <= x < 1024, '
                         'fractional allowed: the read gate opens when the timebase '
                         'reaches floor(x) and the symbol period is round((x-floor(x))*'
                         'count_max) clocks in, so the first symbol sent sits at position '
                         'x+1; 0 = start as soon as possible (default %g)' % DEF_TIME_SEL)
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    if not 0.0 <= args.tsel < 1024.0:
        raise SystemExit('--tsel %g out of range: 0 <= x < 1024' % args.tsel)

    size_kb = parse_size_kb(args.size)
    pkt = build_packet(args.single, size_kb, args.tsel)

    # what adhocSoft.c will make of it: BPSK is 1 bit per symbol
    sym_num = int(size_kb * BITS_PER_KB + 0.5)
    tsel = struct.unpack_from('<d', pkt, OFF_TIME_SEL)[0]

    rs = 400e3 if args.rate == 1 else 450e3       # bpsk symbol rate
    rate_label = '400 kHz' if args.rate == 1 else '450 kHz'
    ts_int, ts_clk = split_time_sel(tsel, args.rate)
    count_max = CLK_PER_SYM_400K if args.rate == 1 else CLK_PER_SYM_450K

    if not pkt[OFF_SINGLE_SHOT]:
        turn = ('the whole table (4194304 symbols)' if sym_num == 0
                else '%d symbols' % sym_num)
        burst = 'cyclic: %s per turn, then back to symbol 0, forever' % turn
    elif sym_num == 0:
        burst = 'single shot, sends nothing'
    else:
        burst = 'single shot, %.6f s (%d symbols at %s)' % (
            sym_num / rs, sym_num, rate_label)
    if sym_num > TABLE_KB * BITS_PER_KB:
        burst += ' [longer than the table, it repeats within a turn]'

    print('=== case 135 tx start pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('burst   : single_shot=%d  size=%.6f kB (%d bytes) -> %d bits'
          % (pkt[OFF_SINGLE_SHOT], size_kb, int(round(size_kb * 1024)), sym_num))
    print('          %s' % burst)
    print('time_sel: %g  (first symbol at position %g)' % (tsel, tsel + 1))
    print('          0x718 = %d, 0x71C = %d/%d clk  [%s, assumes tx_configure.py --rate '
          'matches]' % (ts_int, ts_clk, count_max, rate_label))
    if tsel:
        print('          gate opens at timebase %d, clock %d of that symbol period; no '
              'waiting: both values land while reset holds the timebase at 0'
              % (ts_int, ts_clk))
    if ts_clk % 50:
        print('          note: the RF envelope only moves in 50-clk steps (the first '
              'zero_interpolator slot grid, 1/8 symbol), so this offset lands on clock '
              '%d of that grid' % (ts_clk - ts_clk % 50))
    print('note    : tx_start() runs on the board -- freq / atten / enable / rate '
          'come from the last tx_configure.py.')
    print(hex_dump(pkt))

    if args.dry_run:
        print('--dry-run: not sent.')
        return

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.settimeout(1)
        n = s.sendto(pkt, (args.ip, args.port))
        print('sent %d bytes -> %s:%d' % (n, args.ip, args.port))
    except OSError as e:
        print('send failed: %s' % e)
        raise SystemExit(1)
    finally:
        s.close()


if __name__ == '__main__':
    main()
