#!/usr/bin/env python3
"""
send_symbol_table.py
Upload a symbol table to a node's TX symbol RAM over UDP, packed
according to case 134 of the //20260902 edit in adhocSoft.c.

Run send_tx_init.py LAST -- configuring the RAM and initializing the
transmitter are decoupled, and this is the order they have to happen in:

    1. this script uploads the table (case 134).  The board accumulates
       every chunk in its own buffer and only writes the RAM once the
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
    2..3      chunk_idx                  u16 little-endian
    4..1027   512 words                  u16 little-endian, 1024 bytes

    Total length = 1028 bytes.

    chunk_idx is the index of this chunk inside the table, NOT a word
    offset -- the board multiplies it by 512.  The two tables have
    different lengths, so the number of chunks in a table follows
    table_sel:

        BPSK  262144 words (512 KB) = 512 chunks
        QPSK   32768 words ( 64 KB) =  64 chunks

    The RAM write address auto-increments in the PL, so the chunks must
    arrive strictly in order.  chunk_idx 0 starts a new table (and mutes
    the transmitter); the last chunk makes the board write the RAM.  A
    lost or reordered packet is detected and dropped by the board --
    rerun this script to resend the whole table.

    The ARM is little-endian, so every u16 is packed with '<H'.

Table file: raw little-endian u16.  A file *shorter* than the table is
accepted and zero-padded out to the full length, so a short file is a way
to transmit only a prefix and leave the rest of the table at the zero word
(all-zero symbols).  The padding is reported, not silent.

A file *longer* than the table is an error: the extra data would be
silently dropped, so the file would then not be the table you think it is.

gen_symbol_table.py writes the full length for whichever --table-sel you
give it.  Because a short file is now accepted, sending the 64 KB QPSK
table with --table-sel bpsk would pad 87.5% zeros instead of failing, so
that exact mix-up is called out with a warning.

Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
listening port, see adhocSoft.c).

One run fills exactly one table. To fill both tables, run it twice --
there is no "both": the two bursts would run back to back with no way to
tell them apart on the wire.

Examples (this is the order they run in):
    python gen_symbol_table.py -o symbols.bin --table-sel bpsk
    python send_symbol_table.py --table symbols.bin --table-sel bpsk --dry-run
    python send_symbol_table.py --table symbols.bin --table-sel bpsk
    python send_symbol_table.py --table symbols.bin --table-sel qpsk
    python send_tx_init.py --bpsk-freq 100 --qpsk-freq 200
"""

import argparse
import array
import os
import socket
import struct
import sys
import time

CMD_TABLE_CHUNK = 134

# Must match pcie_tx.h / adhocSoft.c
TABLE_SEL = {'bpsk': 0, 'qpsk': 1}
RAM_TABLE_WORDS = {'bpsk': 262144, 'qpsk': 32768}
CHUNK_WORDS = 512
CHUNK_BYTES = 2 * CHUNK_WORDS
PKT_LEN = 4 + CHUNK_BYTES
PROGRESS_EVERY = 64


def build_chunk(table_sel, chunk_idx, words):
    """Pack one case 134 chunk; return bytes(1028).

    words is a sequence of ints; chunk_idx is the index of the chunk
    words[0] belongs to.
    """
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_TABLE_CHUNK
    buf[1] = table_sel & 0xFF
    struct.pack_into('<H', buf, 2, chunk_idx)
    struct.pack_into('<%dH' % CHUNK_WORDS, buf, 4, *words)
    return bytes(buf)


def load_table(path, n_words, sel_name):
    """Read a .bin symbol table; return (words, file_words).

    words is an array of exactly n_words u16 -- the file zero-padded at the
    end if it is short.  file_words is the word count actually in the file,
    so the caller can report how much was padded.

    Longer than the table is an error rather than a silent truncation.
    """
    if not os.path.isfile(path):
        raise SystemExit('table file not found: %s' % path)
    if os.path.splitext(path)[1].lower() != '.bin':
        raise SystemExit(
            'table %s: must be a .bin file (little-endian u16), '
            'see gen_symbol_table.py' % path)

    raw = open(path, 'rb').read()
    if len(raw) > n_words * 2:
        raise SystemExit(
            'table %s: %d bytes, longer than the %s table (%d bytes = %d '
            'words) -- refusing to truncate, see gen_symbol_table.py'
            % (path, len(raw), sel_name.upper(), n_words * 2, n_words))
    if len(raw) % 2:
        raise SystemExit(
            'table %s: %d bytes is an odd length, so it is not a whole '
            'number of u16 words' % (path, len(raw)))

    words = array.array('H')
    words.frombytes(raw)
    file_words = len(words)
    if file_words < n_words:
        words.extend([0] * (n_words - file_words))
    if sys.byteorder != 'little':
        words.byteswap()
    return words, file_words


def send(sock, pkt, addr):
    return sock.sendto(pkt, addr)


def main():
    ap = argparse.ArgumentParser(
        description='Upload a symbol table to the TX symbol RAM (case 134). '
                    'Run send_tx_init.py afterwards to start transmitting.')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--table', metavar='FILE', required=True,
                    help='symbol table .bin file; shorter than the full table is '
                         'zero-padded, longer is an error (BPSK full = 524288 bytes '
                         '= 262144 words, QPSK full = 65536 bytes = 32768 words)')
    ap.add_argument('--table-sel', choices=['bpsk', 'qpsk'], required=True,
                    help='which table to fill (required); sets both the expected '
                         'chunk count and the table length the file must match')
    ap.add_argument('--gap', type=float, default=0.005,
                    help='seconds between chunks (default 0.005); the lwIP UDP '
                         'recvmbox is shallow, a back-to-back burst drops packets')
    ap.add_argument('--dry-run', action='store_true',
                    help='load/check the table and print the plan, do not send')
    args = ap.parse_args()

    sel = TABLE_SEL[args.table_sel]
    n_words = RAM_TABLE_WORDS[args.table_sel]
    n_chunks = n_words // CHUNK_WORDS
    other_sel = 'qpsk' if args.table_sel == 'bpsk' else 'bpsk'

    table, file_words = load_table(args.table, n_words, args.table_sel)

    print('=== symbol table %s ===' % args.table)
    print('file    : %d words (%d bytes)' % (file_words, file_words * 2))
    print('table   : %s, %d words (%.1f Kbit)'
          % (args.table_sel.upper(), n_words, n_words * 16 / 1024.0))
    if file_words < n_words:
        print('padding : %d words of zero at the end (%.1f%% of the table)'
              % (n_words - file_words,
                 100.0 * (n_words - file_words) / n_words))
        if file_words == RAM_TABLE_WORDS[other_sel]:
            print('WARNING : that is exactly the %s table length. If you meant '
                  'the %s table, re-run with --table-sel %s.'
                  % (other_sel.upper(), other_sel.upper(), other_sel))
    print('first 8 : ' + ' '.join('0x%04X' % w for w in table[:8]))
    print('sel     : %s -> %d' % (args.table_sel, sel))
    print('chunks  : %d x %d bytes = %d bytes'
          % (n_chunks, PKT_LEN, n_chunks * PKT_LEN))
    print('upload  : about %.1f s at --gap %g' % (n_chunks * args.gap, args.gap))

    if args.dry_run:
        print('--dry-run: not sent.')
        return

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.settimeout(1)
        addr = (args.ip, args.port)
        for idx in range(n_chunks):
            off = idx * CHUNK_WORDS
            chunk = build_chunk(sel, idx, table[off:off + CHUNK_WORDS])
            send(s, chunk, addr)
            if (idx + 1) % PROGRESS_EVERY == 0:
                print('  sent %d/%d chunks' % (idx + 1, n_chunks))
            if args.gap > 0 and idx != n_chunks - 1:
                time.sleep(args.gap)
        print('done: sel=%d, %d chunks (%d bytes) sent, last chunk_idx %d'
              % (sel, n_chunks, n_chunks * PKT_LEN, n_chunks - 1))
        print('the board starts transmitting when the last chunk of a table lands')
    except OSError as e:
        print('send failed: %s' % e)
        raise SystemExit(1)
    finally:
        s.close()


if __name__ == '__main__':
    main()
