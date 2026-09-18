#!/usr/bin/env python3
"""
gen_symbol_table.py
Generate a random symbol table file: little-endian u16, every word an
independent uniform 16-bit value.  The size is arbitrary -- pick it with
--words, --bytes, or the --table-sel shorthand for a full TX table:

    --table-sel bpsk   262144 words = 524288 bytes = 512 KB (full table)
    --table-sel qpsk    32768 words =  65536 bytes =  64 KB (full table)

Nothing here knows about modulation. The file is just a run of numbers;
what the numbers mean once they are in the RAM is the RTL's business, and
which table they end up in is decided by tx_ram_configure.py.

A file shorter than the table it is sent to is zero-padded by
tx_ram_configure.py, so a short file leaves the tail of the transmission
at the zero word (all-zero symbols).  Nothing longer than a full table can
ever be sent, so the size is capped at 512 KB -- ask for more and this
exits with an error instead of writing a file with nowhere to go.

The seed is printed so a table can be reproduced later with --seed; without
--seed one is drawn from the system entropy pool.

Sizes accept a 1024-based K/M/G suffix, with or without a trailing B:
512K, 512KB, 1M, 1MB all mean what you expect.

Examples:
    python gen_symbol_table.py -o symbols.bin --table-sel bpsk
    python gen_symbol_table.py -o symbols.bin --table-sel qpsk --seed 0xC0FFEE
    python gen_symbol_table.py -o prefix.bin --words 1000        # 2000 bytes
    python gen_symbol_table.py -o big.bin --bytes 256K           # 131072 words
"""

import argparse
import array
import os
import random
import sys

# Must match tx_ram_configure.py and adhocSoft.c
RAM_TABLE_WORDS = {'bpsk': 262144, 'qpsk': 32768}
# Largest table the transmitter can hold (BPSK: 262144 words = 524288 bytes =
# 512 KB).  Hard cap -- a longer file could never be sent, so generating one is
# an error rather than something to warn about.
MAX_TABLE_WORDS = max(RAM_TABLE_WORDS.values())


def parse_count(s):
    """Parse a word/byte count with an optional 1024-based K/M/G suffix.

    "512", "512K", "512KB", "1M", "1MB" -> 512, 524288, 524288, 1048576,
    1048576.  Raises for anything that is not a positive count.
    """
    t = s.strip().upper()
    mult = 1
    for suffix, m in (('G', 1024 ** 3), ('M', 1024 ** 2), ('K', 1024)):
        if t.endswith(suffix + 'B'):
            mult, t = m, t[:-2]
            break
        if t.endswith(suffix):
            mult, t = m, t[:-1]
            break
    else:
        if t.endswith('B'):        # plain bytes, no K/M/G
            t = t[:-1]

    try:
        n = int(t)
    except ValueError:
        raise argparse.ArgumentTypeError('not a count: %r' % s)
    if n <= 0:
        raise argparse.ArgumentTypeError('must be positive: %r' % s)
    return n * mult


def main():
    ap = argparse.ArgumentParser(
        description='Generate a random symbol table file (.bin) for the TX '
                    'symbol RAM, of any size.')

    ap.add_argument('-o', '--out', metavar='FILE', required=True,
                    help='output file; must end in .bin')

    size = ap.add_mutually_exclusive_group(required=True)
    size.add_argument('--table-sel', choices=['bpsk', 'qpsk'],
                      help='shorthand for a full table: bpsk 262144 words '
                           '(512 KB), qpsk 32768 words (64 KB)')
    size.add_argument('--words', type=parse_count, metavar='N',
                      help='word count (u16), max 262144; accepts a K/M/G '
                           'suffix, e.g. 256K')
    size.add_argument('--bytes', type=parse_count, metavar='N',
                      help='file size in bytes, even, max 524288 = 512 KB; '
                           'accepts a K/M/G suffix, e.g. 256K')

    ap.add_argument('--seed', type=lambda s: int(s, 0),
                    help='random seed, to make the table reproducible '
                         '(default: drawn from system entropy)')
    args = ap.parse_args()

    if os.path.splitext(args.out)[1].lower() != '.bin':
        raise SystemExit('output must be a .bin file: tx_ram_configure.py '
                         'reads .bin only')

    if args.table_sel:
        n_words = RAM_TABLE_WORDS[args.table_sel]
        source = '--table-sel %s' % args.table_sel
    elif args.words is not None:
        n_words = args.words
        source = '--words %d' % args.words
    else:
        if args.bytes % 2:
            ap.error('--bytes must be even: the table is a stream of u16 words')
        n_words = args.bytes // 2
        source = '--bytes %d' % args.bytes

    # Checked before anything is allocated or written: refuse rather than
    # produce a file that tx_ram_configure.py would only reject.
    if n_words > MAX_TABLE_WORDS:
        ap.error('size too large: %d words = %d bytes, but the largest TX table '
                 'is %d words = %d bytes (512 KB) and nothing longer can be sent'
                 % (n_words, n_words * 2, MAX_TABLE_WORDS, MAX_TABLE_WORDS * 2))

    seed = args.seed
    if seed is None:
        seed = random.SystemRandom().getrandbits(32)

    rnd = random.Random(seed)
    words = array.array('H', (rnd.getrandbits(16) for _ in range(n_words)))
    if sys.byteorder != 'little':
        words.byteswap()

    with open(args.out, 'wb') as f:
        f.write(words.tobytes())

    print('=== random symbol table -> %s ===' % args.out)
    print('source  : %s' % source)
    print('words   : %d (%.1f Kbit)' % (n_words, n_words * 16 / 1024.0))
    print('bytes   : %d' % (n_words * 2))
    print('seed    : 0x%08X   (pass --seed 0x%08X to reproduce)' % (seed, seed))
    print('first 8 : ' + ' '.join('0x%04X' % w for w in words[:8]))
    if n_words < MAX_TABLE_WORDS:
        print('note    : shorter than a full table -- tx_ram_configure.py will '
              'zero-pad the rest')


if __name__ == '__main__':
    main()
