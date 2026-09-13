#!/usr/bin/env python3
"""
send_symbol_table.py
Upload a symbol table to a node's TX symbol RAM over UDP, packed
according to case 134 of the //20260902 edit in adhocSoft.c.

Run send_tx_init.py LAST -- configuring the RAM and initializing the
transmitter are decoupled, and this is the order they have to happen in:

    1. this script uploads the table (case 134).  The board accumulates
       all 64 chunks in its own buffer and only writes the RAM once the
       last one lands, so a partial upload never reaches the PL.  There
       is nothing to transmit from yet, and the transmitter is still
       held off.
    2. send_tx_init.py then sends case 133, which runs tx_init(): it
       resets the read pointer to 0, applies the DDS frequencies /
       attenuations / enables, and switches the RAM read enable on.
       That is the moment playback starts.

Both the write pointer and the read pointer are at 0 when transmission
begins, so the table plays from its first word.  Initializing first would
switch the RAM read enable on while the RAM still holds nothing (the
BRAM has no power-up contents) and let the read pointer run across the
whole upload.

case 134 payload layout (UDP payload == raw pBuf; the Ethernet control
socket has no frame header and no CRC):

    offset    field                      type
    ---------------------------------------------
    0         command = 134              u8
    1         table_sel                  u8 (0 = BPSK, 1 = QPSK)
    2..3      word_offset                u16 little-endian (0, 512, ... 32256)
    4..1027   512 words                  u16 little-endian, 1024 bytes

    Total length = 1028 bytes. One table = 32768 words = 64 packets.

    The RAM write address auto-increments in the PL, so the chunks must
    arrive strictly in order. Offset 0 starts a new table (and mutes the
    transmitter); the last chunk makes the board call tx_init() and start
    transmitting. A lost or reordered packet is detected and dropped by
    the board -- rerun this script to resend the whole table.

    The ARM is little-endian, so every u16 is packed with '<H'.

Table file: raw little-endian u16, 65536 bytes = 32768 words, exactly what
gen_symbol_table.py writes.  Nothing else is accepted -- a text table, a
short file or a long one is an error, never something to pad or guess at.

Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
listening port, see adhocSoft.c).

One run fills exactly one table, always 64 chunks. To fill both tables,
run it twice -- there is no "both": the two 64-chunk bursts would run
back to back with no way to tell them apart on the wire.

Examples (this is the order they run in):
    python gen_symbol_table.py -o symbols.bin
    python send_symbol_table.py --table symbols.bin --table-sel bpsk --dry-run
    python send_symbol_table.py --table symbols.bin --table-sel bpsk
    python send_symbol_table.py --table symbols.bin --table-sel qpsk
    python send_tx_init.py --bpsk-freq 100 --qpsk-freq 200
"""

import argparse
import os
import socket
import struct
import time

CMD_TABLE_CHUNK = 134

# Must match pcie_tx.h
RAM_TABLE_WORDS = 32768
CHUNK_WORDS = 512
CHUNK_BYTES = 2 * CHUNK_WORDS
PKT_LEN = 4 + CHUNK_BYTES
N_CHUNKS = RAM_TABLE_WORDS // CHUNK_WORDS

TABLE_SEL = {'bpsk': 0, 'qpsk': 1}


def build_chunk(table_sel, word_offset, words):
    """Pack one case 134 chunk; return bytes(1028).

    words is a sequence of ints; word_offset is the index of words[0]
    inside the table.
    """
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_TABLE_CHUNK
    buf[1] = table_sel & 0xFF
    struct.pack_into('<H', buf, 2, word_offset)
    struct.pack_into('<%dH' % CHUNK_WORDS, buf, 4, *words)
    return bytes(buf)


def load_table(path):
    """Read a .bin symbol table; return a list of exactly 32768 ints.

    Exits with an error rather than truncating or padding: a table of the
    wrong length means the file is not the table you think it is.
    """
    if not os.path.isfile(path):
        raise SystemExit('table file not found: %s' % path)
    if os.path.splitext(path)[1].lower() != '.bin':
        raise SystemExit(
            'table %s: must be a .bin file (%d bytes, little-endian u16), '
            'see gen_symbol_table.py' % (path, RAM_TABLE_WORDS * 2))

    raw = open(path, 'rb').read()
    if len(raw) != RAM_TABLE_WORDS * 2:
        raise SystemExit(
            'table %s: %d bytes, expected %d (%d words x 2)'
            % (path, len(raw), RAM_TABLE_WORDS * 2, RAM_TABLE_WORDS))
    return list(struct.unpack('<%dH' % RAM_TABLE_WORDS, raw))


def send(sock, pkt, addr):
    return sock.sendto(pkt, addr)


def main():
    ap = argparse.ArgumentParser(
        description='Upload a symbol table to the TX symbol RAM (case 134). '
                    'Run send_tx_init.py first to set the DDS frequencies / '
                    'attenuations / enables.')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--table', metavar='FILE', required=True,
                    help='symbol table .bin file (65536 bytes = 32768 words)')
    ap.add_argument('--table-sel', choices=['bpsk', 'qpsk'], required=True,
                    help='which table to fill (required); one run fills exactly '
                         'one table = 64 chunks, run it again for the other')
    ap.add_argument('--gap', type=float, default=0.005,
                    help='seconds between chunks (default 0.005); the lwIP UDP '
                         'recvmbox is shallow, a back-to-back burst drops packets')
    ap.add_argument('--dry-run', action='store_true',
                    help='load/check the table and print the plan, do not send')
    args = ap.parse_args()

    table = load_table(args.table)
    sel = TABLE_SEL[args.table_sel]

    print('=== symbol table %s ===' % args.table)
    print('words   : %d (%.1f Kbit)' % (len(table), len(table) * 16 / 1024.0))
    print('first 8 : ' + ' '.join('0x%04X' % w for w in table[:8]))
    print('sel     : %s -> %d' % (args.table_sel, sel))
    print('chunks  : %d x %d bytes = %d bytes'
          % (N_CHUNKS, PKT_LEN, N_CHUNKS * PKT_LEN))
    print('tx time : about %.1f s at --gap %g' % (N_CHUNKS * args.gap, args.gap))

    if args.dry_run:
        print('--dry-run: not sent.')
        return

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.settimeout(1)
        addr = (args.ip, args.port)
        for idx in range(N_CHUNKS):
            off = idx * CHUNK_WORDS
            chunk = build_chunk(sel, off, table[off:off + CHUNK_WORDS])
            send(s, chunk, addr)
            if args.gap > 0 and idx != N_CHUNKS - 1:
                time.sleep(args.gap)
        print('done: sel=%d, %d chunks (%d bytes) sent, last offset %d'
              % (sel, N_CHUNKS, N_CHUNKS * PKT_LEN, (N_CHUNKS - 1) * CHUNK_WORDS))
        print('the board starts transmitting when the last chunk of a table lands')
    except OSError as e:
        print('send failed: %s' % e)
        raise SystemExit(1)
    finally:
        s.close()


if __name__ == '__main__':
    main()
