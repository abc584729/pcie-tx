#!/usr/bin/env python3
"""
tx_stop.py
Send the UDP "stop transmission" command packet to a node, packed according
to case 136 of the //20260902 edit in adhocSoft.c.

case 136 payload layout (UDP payload == raw pBuf; the Ethernet control
socket has no frame header and no CRC):

    offset   field                      type
    ---------------------------------------------
    0        command = 136              u8

    Total length = 1 byte. There is no payload -- the command *is* the action,
    so a short packet cannot be a half-written one.

On the board it is one write and nothing else:

    emc_write(TX_REG_RAM_EN, 0);        /* 0x702 = 0, close the RAM read gate */

That shuts the BPSK read gate in rtl/bpsk_ram.v, so no further symbols come
out of the symbol table. It does **not** pulse TX_REG_RESET: the symbol
divider (`count`) and the timebase counter (`cnt_1024`) are cleared only by
rst_n, so they keep free-running and the reference timebase is preserved.

Two side effects come along, both because `rd_en` goes low in bpsk_ram.v:

  * the read pointer and the symbol counter are cleared, so whatever starts
    next begins at symbol 0 no matter where this stop interrupted -- getting
    back to the table head needs no reset;
  * the data already in the filter chain drains normally and the DAC tvalid
    falls on its own (README §3.4), so the output mutes rather than being cut
    mid-symbol. The enable bits are not touched: bpsk_en / qpsk_en stay as
    they are, and the DDS keeps running.

To transmit again, either

  * re-open the gate with 0x702 = 1 -- one write, no reset, so the timebase
    carries straight on (the gate reopens only on the single clock where
    cnt_1024 == time_sel AND count == clock_sel, so resumption can take up to
    one lap: 1024 symbols, ~2.276 ms at 450k / ~2.56 ms at 400k). It uses the
    0x718 / 0x71C values already in the registers -- this path rewrites
    neither, so the start point, sub-symbol offset included, does not move.
    No script here sends that write on its own -- tx_start() always pulses the
    reset; or
  * run tx_start.py (case 135), which pulses TX_REG_RESET inside tx_start().
    Same effect, but the timebase restarts from 0, so the burst comes up at
    the --tsel position of that packet rather than where the previous one sat.

Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
listening port, see adhocSoft.c).

Examples:
    cd /d
    python tx_stop.py
    python tx_stop.py --dry-run
"""

import argparse
import socket

CMD_TX_STOP = 136

PKT_LEN = 1             # the command byte is the whole packet


def build_packet():
    """Pack the payload per the case 136 layout; return bytes(1)."""
    return bytes([CMD_TX_STOP])


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
        description='Send the //20260902 case 136 stop command: close the RAM '
                    'read gate (0x702 = 0). No reset, so the transmit timebase '
                    'keeps running.')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    pkt = build_packet()

    print('=== case 136 tx stop pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('action  : emc_write(TX_REG_RAM_EN, 0)  -- read gate closed, no reset')
    print('effect  : output mutes as the filter chain drains; timebase keeps '
          'running; read pointer and symbol count cleared, so the next start '
          'begins at symbol 0.')
    print('restart : tx_start.py (case 135) -- note it resets the timebase, so '
          'the next burst starts at that packet\'s --tsel position.')
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
