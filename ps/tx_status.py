#!/usr/bin/env python3
"""
tx_status.py
Read a PL register back over the Ethernet control port and print it, using
case 137 of the //20260918 edit in adhocSoft.c.

case 137 is case 7 ("read any EMC address") plus a reply. case 7 only
xil_printf's the value to the serial console, which a script cannot use; 137
sends the value back to whoever sent the command:

    request  (3 bytes):  [137, addrL, addrH]
    reply    (5 bytes):  [137, addrL, addrH, valL, valH]

The reply goes to the source address of the request -- adhocCtrl receives with
lwip_recvfrom now instead of lwip_read, so it has the sender. Nothing else has
to be configured: no fixed peer address, no port 32000.

The address this exists for is 0x71A (TX_REG_BPSK_BUSY), a read-only BPSK
transmit status bit. bit0 = 1 while the BPSK chain is transmitting:

    busy <= rd_en & ~stop;      // rtl/bpsk_ram.v

so it rises the moment 0x702 is written and falls when either

  * `stop` asserts -- single-shot finished (done latched) or sym_num == 0, or
  * 0x702 goes back to 0 (tx_stop.py).

Read the semantics twice before trusting it:

  * it does **not** mean "RF is coming out": after 0x702 rises, busy is
    already 1 while the read gate is still waiting for its timebase window
    (up to 1024 symbols -- 2.276 ms at 450k, 2.56 ms at 400k);
  * cyclic mode has no completion edge at all: busy just follows 0x702, so it
    only ever falls when you stop;
  * single-shot with sym_num = 0 is the odd corner -- 0x702 = 1 and busy = 0
    for as long as the gate is held open;
  * bpsk_en is not part of it: mute the output and busy is still 1.

An old bitstream that predates this decodes nothing at 0x71A and returns the
unknown-address fallback 0xAA55, which is how you tell "no such register" from
"busy = 0".

emc_read is a plain MMIO read -- Xil_In32/In16(EMC_BASEADDR1 + addr) in
emc_function.c. There is no PL round-trip and no flag to poll. The cost is on
the UDP side instead: the board's recv_thread does one blocking lwip_read per
loop pass, so every sample is a whole request/reply cycle against that loop.
--interval defaults to 0.2 s to stay courteous to it, not because the read is
slow.

Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl listening
port, see adhocSoft.c).

Examples:
    python tx_status.py                        # one read of 0x71A
    python tx_status.py --watch                # poll until Ctrl-C
    python tx_status.py --watch --count 20     # 20 samples, then a summary
    python tx_status.py --addr 0x702 --bit 0   # any address, any bit
    python tx_status.py --dry-run
"""

import argparse
import socket
import struct
import sys
import time

CMD_READ_REPLY = 137

OFF_ADDR = 1            # request: addr LSB at [1], MSB at [2] (little-endian)
REQ_LEN = 3             # cmd + 2 addr bytes

REP_HDR = 0             # reply: [137, addrL, addrH, valL, valH]
REP_ADDR = 1
REP_VAL = 3
REP_LEN = 5

ADDR_TX_BPSK_BUSY = 0x71A
UNKNOWN_ADDR_FALLBACK = 0xAA55   # what an undecoded address reads back as

DEF_ADDR = ADDR_TX_BPSK_BUSY
DEF_BIT = 0
DEF_INTERVAL = 0.2      # seconds between samples -- one UDP round-trip each
DEF_TIMEOUT = 1.0       # seconds to wait for a reply


def build_request(addr):
    """Pack the case 137 request; return bytes(3)."""
    buf = bytearray(REQ_LEN)
    buf[0] = CMD_READ_REPLY
    struct.pack_into('<H', buf, OFF_ADDR, addr & 0xFFFF)
    return bytes(buf)


def parse_reply(buf, addr):
    """Validate a reply and return (addr, value). Raises SystemExit on junk."""
    if len(buf) < REP_LEN:
        raise SystemExit('short reply: %d bytes, expected %d' % (len(buf), REP_LEN))
    if buf[REP_HDR] != CMD_READ_REPLY:
        raise SystemExit('reply is not a case %d packet (byte0 = %d) -- is another '
                         'tool answering on this port?'
                         % (CMD_READ_REPLY, buf[REP_HDR]))
    rep_addr, val = struct.unpack_from('<HH', buf, REP_ADDR)
    if rep_addr != (addr & 0xFFFF):
        raise SystemExit('reply is for 0x%X, asked for 0x%X' % (rep_addr, addr))
    return rep_addr, val


def describe(addr, bit, val):
    """Human label for the bit being watched."""
    b = (val >> bit) & 0x1
    if addr == ADDR_TX_BPSK_BUSY and bit == 0:
        extra = '  BUSY (transmitting)' if b else '  idle'
        if val == UNKNOWN_ADDR_FALLBACK:
            extra += '  [0xAA55 = address not decoded, bitstream predates 0x71A]'
        return 'bit0 = %d%s' % (b, extra)
    return 'bit%d = %d' % (bit, b)


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
        description='Read a PL register through case 137 of the //20260918 '
                    'edit in adhocSoft.c. Defaults to 0x71A bit0, the BPSK '
                    'transmit status bit.')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--addr', default=hex(DEF_ADDR),
                    help='register address to read, decimal or 0x-prefixed '
                         '(default %s)' % hex(DEF_ADDR))
    ap.add_argument('--bit', type=int, default=DEF_BIT,
                    help='which bit of the 16-bit value to report (default %d)' % DEF_BIT)
    ap.add_argument('--watch', action='store_true',
                    help='keep polling instead of doing a single read')
    ap.add_argument('--count', type=int, default=0,
                    help='with --watch: how many samples to take, 0 = until '
                         'Ctrl-C (default 0)')
    ap.add_argument('--interval', type=float, default=DEF_INTERVAL,
                    help='seconds between samples (default %g); each sample is a '
                         'full UDP round-trip with the board, so do not go much '
                         'below this' % DEF_INTERVAL)
    ap.add_argument('--timeout', type=float, default=DEF_TIMEOUT,
                    help='seconds to wait for each reply (default %g)' % DEF_TIMEOUT)
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    try:
        addr = int(args.addr, 0)
    except ValueError:
        raise SystemExit('bad --addr %r: use 0x71A or 1818' % args.addr)
    if not 0 <= addr <= 0xFFFF:
        raise SystemExit('--addr 0x%X out of range: 0..0xFFFF' % addr)
    if not 0 <= args.bit <= 15:
        raise SystemExit('--bit %d out of range: 0..15' % args.bit)
    if args.count < 0:
        raise SystemExit('--count %d is negative' % args.count)

    req = build_request(addr)

    print('=== case %d read request (len=%d) ===' % (CMD_READ_REPLY, len(req)))
    print('addr    : 0x%03X   watching bit%d' % (addr, args.bit))
    if addr == ADDR_TX_BPSK_BUSY:
        print('          TX_REG_BPSK_BUSY: 1 = BPSK transmitting, 0 = idle. High as '
              'soon as 0x702 is written,\n          and it does not mean RF is out '
              'yet (the gate may still be waiting for its timebase window).')
    print(hex_dump(req))

    if args.dry_run:
        print('--dry-run: not sent.')
        return

    samples = args.count if args.watch else 1
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(args.timeout)

    taken = failed = busy = edges = 0
    prev = None
    try:
        while samples == 0 or taken < samples:
            taken += 1
            try:
                s.sendto(req, (args.ip, args.port))
            except OSError as e:
                raise SystemExit('send failed: %s' % e)

            try:
                buf, peer = s.recvfrom(1400)
            except socket.timeout:
                failed += 1
                print('%s  no reply within %.2f s'
                      % (time.strftime('%H:%M:%S'), args.timeout))
                if not args.watch:
                    break
                continue

            _, val = parse_reply(buf, addr)
            bit = (val >> args.bit) & 0x1
            if bit:
                busy += 1
            if prev is not None and bit != prev:
                edges += 1
            prev = bit
            print('%s  addr 0x%03X = 0x%04X   %s'
                  % (time.strftime('%H:%M:%S'), addr, val, describe(addr, args.bit, val)))

            if samples == 0 or taken < samples:
                time.sleep(args.interval)
    except KeyboardInterrupt:
        print('\nstopped.')
    finally:
        s.close()

    if taken > 1:
        print('--- %d samples, %d failed, bit%d high %d time(s), %d transition(s) ---'
              % (taken, failed, args.bit, busy, edges))
    if failed:
        sys.exit(1)


if __name__ == '__main__':
    main()
