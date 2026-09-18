#!/usr/bin/env python3
"""
tx_time_calibration.py
Send the UDP "BPSK start position" command packet to a node, packed according
to case 136 of the //20260902 edit in adhocSoft.c.

This is the timing-calibration half of the old send_tx_init.py: it sets where
in the 1024-symbol timebase the BPSK read gate opens, which is how you place
the start of a burst at a known, repeatable position on a scope.

case 136 payload layout (UDP payload == raw pBuf; the Ethernet control
socket has no frame header and no CRC):

    offset   field                      type
    ---------------------------------------------
    0        command = 136              u8
    1..2     bpsk_time_sel              u16 (2B, little-endian) 0..1023

    Total length = 3 bytes.

    bpsk_time_sel is where in the 1024-symbol timebase the BPSK read gate
    opens. The timebase is 1024 symbols long (450k: 400*1024 clk = 2.276 ms;
    400k: 450*1024 = 2.56 ms) and is driven by the same divider pulse that
    reads the table, so the pulse that matches bpsk_time_sel is spent opening
    the gate and reads nothing: the first symbol actually transmitted sits at
    timebase position bpsk_time_sel + 1. 0 = open it on the very first pulse
    after reset (= start as soon as possible, the behaviour without this
    field). Only the PS path uses it -- in VIO mode the top level ties it to 0.

    This applies *at runtime*, with no reset anywhere: 0x718 is written live
    using stop -> write -> start (set_bpsk_time_sel_runtime() in pcie_tx.c).
    TX_REG_RESET must never be pulsed here -- the symbol divider and the
    timebase counter are cleared only by rst_n, so a reset would zero the
    reference timebase and the calibration would be meaningless. Instead:

        1. 0x702 = 0   lower ram_en -> the read gate closes on the next clock
                       and output stops; the divider and the timebase keep
                       free-running, they are not gated by ram_en
        2. write 0x718 the timebase never stopped, so the new value is picked
                       up on the next lap, when cnt_1024 == time_sel
        3. 0x702 = 1   reopen the gate

    The cost of avoiding a reset is step 3: the gate only opens on the one
    clock where cnt_1024 == time_sel, which comes round once per lap, so
    output can take up to one full lap (1024 symbols; 2.276 ms at 450k,
    2.56 ms at 400k) to resume.

    Caveat -- single-shot mode: a burst that already finished holds `done`
    (cleared only by rst_n too), so stop/start will not begin it again. In
    single-shot, restart with tx_start.py (case 135) instead.

    tx_init() now writes the global (not a hardcoded 0), so whatever this
    command last set survives a later tx_start.py.

    Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
    listening port, see adhocSoft.c).

Examples:
    cd /d
    python tx_time_calibration.py --tsel 500           # open the gate at count 500
    python tx_time_calibration.py --tsel 0             # back to "start ASAP"
    python tx_time_calibration.py --tsel 500 --rate 1 --dry-run

    Safe to send while transmitting: it briefly stops the output and resumes
    it within one timebase lap, without resetting anything.
"""

import argparse
import socket
import struct

CMD_TX_TIME_CAL = 136

OFF_TIME_SEL = 1

PKT_LEN = 3             # cmd + time_sel u16

# time_sel is 10 bit: 1024 symbols per timebase frame
TIME_SEL_MAX = 1023

# rate_sel -> bpsk symbol rate, for the printout only
RATE_SEL_BPSK_HZ = {0: 450e3, 1: 400e3}

DEF_TIME_SEL = 0       # 0 = open the read gate on the first pulse (start ASAP)


RATE_SEL_LABEL = {0: '450k', 1: '400k'}


def fmt_delay(nsym, sym_rate):
    """Duration of `nsym` symbols at `sym_rate`, for the printout."""
    return '~%.3f ms' % (nsym / sym_rate * 1e3)


def build_packet(time_sel):
    """Pack the payload per the case 136 layout; return bytes(3)."""
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_TX_TIME_CAL
    struct.pack_into('<H', buf, OFF_TIME_SEL, int(time_sel) & 0x3FF)
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
        description='Send the //20260902 case 136 BPSK start-position command '
                    '(applied at runtime: stop -> write 0x718 -> start, no reset).')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--tsel', type=int, default=DEF_TIME_SEL,
                    help='BPSK start position in the 1024-symbol timebase, 0..%d: the read '
                         'gate opens when the timebase count reaches it, so the first '
                         'symbol sent sits at position tsel+1; 0 = start as soon as '
                         'possible (default %d)' % (TIME_SEL_MAX, DEF_TIME_SEL))
    ap.add_argument('--rate', type=int, choices=(0, 1), default=0,
                    help='bpsk symbol rate of the *current* board setup, for the printout '
                         'only (0 = 450k, 1 = 400k; default 0)')
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    if not 0 <= args.tsel <= TIME_SEL_MAX:
        raise SystemExit('--tsel %d out of range: 0..%d' % (args.tsel, TIME_SEL_MAX))

    pkt = build_packet(args.tsel)
    tsel = struct.unpack_from('<H', pkt, OFF_TIME_SEL)[0]
    rs = RATE_SEL_BPSK_HZ[args.rate]

    print('=== case 136 tx time calibration pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('time_sel: %d  (first symbol at position %d)' % (tsel, tsel + 1))
    print('resume  : gate reopens within one timebase lap (1024 symbols, %s '
          'at %s)' % (fmt_delay(1024, rs), RATE_SEL_LABEL[args.rate]))
    print('note    : applied live -- 0x702=0 (stop) -> 0x718 -> 0x702=1 (start). '
          'No reset is pulsed, so the reference timebase keeps running.')
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
