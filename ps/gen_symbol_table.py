#!/usr/bin/env python3
"""
gen_symbol_table.py
Generate a framed symbol table file: little-endian u16, split into 1024-bit
frames whose first 7 bits are a sync header and whose remaining 1017 bits are
random.  Frames alternate odd, even, odd, even ... starting with odd, and the
two headers are complements of each other:

    odd  frame: 1011000
    even frame: 0100111

The table is read out LSB-first (dpram takes the group index from the LSB side
of the word), so the first bit of a frame is bit 0 of the word that starts it
and a header written above in transmission order packs left to right into
bits 0..6.  A frame is 1024 bits = 64 words = 128 bytes, and only the first
word of a frame is stamped -- the other 63 words are entirely random.

Pick the size with --words, --bytes, or the --table-sel shorthand for a full
TX table:

    --table-sel bpsk   262144 words = 524288 bytes = 512 KB = 4096 frames
    --table-sel qpsk    32768 words =  65536 bytes =  64 KB =  512 frames

The size must be a multiple of 2 KB, i.e. a whole number of 16-frame groups.
16 frames is 8 odd + 8 even, so a file always ends on an even frame and the
next burst starts on odd again -- the odd/even phase does not drift across a
re-send.  Anything else is rejected rather than written.

Nothing here knows about modulation.  Which table the file ends up in is
decided by tx_ram_configure.py.

A file shorter than the table it is sent to is zero-padded by
tx_ram_configure.py, so a short file leaves the tail of the transmission at
the zero word -- all-zero symbols, which are not frames and will not
correlate.  Nothing longer than a full table can ever be sent, so the size is
capped at 512 KB; ask for more and this exits with an error instead of
writing a file with nowhere to go.

The seed is printed so a table can be reproduced later with --seed; without
--seed one is drawn from the system entropy pool.

Sizes accept a 1024-based K/M/G suffix, with or without a trailing B:
512K, 512KB, 1M, 1MB all mean what you expect.

Examples:
    python gen_symbol_table.py -o 512KB.bin --table-sel bpsk
    python gen_symbol_table.py -o 64KB.bin  --table-sel qpsk
    python gen_symbol_table.py -o part.bin --bytes 256K --seed 0xC0FFEE
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

# Frame format.  A frame is 1024 bits: 7 bits of sync header, 1017 of payload.
FRAME_BITS = 1024
SYNC_BITS = 7
FRAME_WORDS = FRAME_BITS // 16          # 64 words per frame
FRAME_BYTES = FRAME_BITS // 8           # 128 bytes per frame
# Shortest run that keeps the odd/even phase aligned, and the granularity every
# size must land on: 2048 bytes = 16 frames = 8 odd + 8 even.
UNIT_BYTES = 2048
FRAMES_PER_UNIT = UNIT_BYTES // FRAME_BYTES     # 16 frames per 2 KB

# Written in transmission order; packed into bits 0..6 of the frame's first
# word.  Odd and even are bitwise complements, so bit 6 doubles as the parity
# of the frame index.
SYNC_ODD = '1011000'
SYNC_EVEN = '0100111'


def sync_value(pattern):
    """Pack a sync pattern into the low bits of the word that starts a frame.

    The pattern is written in transmission order and the table is read out
    LSB-first, so the first character lands in bit 0: '1011000' -> 0b0001101.
    """
    v = 0
    for i, b in enumerate(pattern):
        if b == '1':
            v |= 1 << i
        elif b != '0':
            raise ValueError('sync pattern must be all 0/1: %r' % pattern)
    if len(pattern) != SYNC_BITS:
        raise ValueError('sync pattern must be %d bits: %r' % (SYNC_BITS, pattern))
    return v


SYNC_WORDS = (sync_value(SYNC_ODD), sync_value(SYNC_EVEN))   # 0x0D, 0x72
SYNC_MASK = (1 << SYNC_BITS) - 1


def stamp_frames(words):
    """Overwrite the low 7 bits of every 64th word with that frame's header.

    Frames run odd, even, odd ... from the start of the file, so frame f takes
    SYNC_WORDS[f % 2].  Only the header word is touched; the rest of the frame
    keeps its random bits.
    """
    for frame in range(len(words) // FRAME_WORDS):
        i = frame * FRAME_WORDS
        words[i] = (words[i] & ~SYNC_MASK) | SYNC_WORDS[frame % 2]


def frame_header(words, frame):
    """Decode a stamped header back to a bit string, for the summary print."""
    w = words[frame * FRAME_WORDS]
    return ''.join('1' if (w >> i) & 1 else '0' for i in range(SYNC_BITS))


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
        description='Generate a framed symbol table file (.bin) for the TX '
                    'symbol RAM: 1024-bit frames, %d-bit sync header (%s odd / '
                    '%s even) alternating odd first, random payload.  Sizes are '
                    'a multiple of 2 KB.' % (SYNC_BITS, SYNC_ODD, SYNC_EVEN))

    ap.add_argument('-o', '--out', metavar='FILE', required=True,
                    help='output file; must end in .bin')

    size = ap.add_mutually_exclusive_group(required=True)
    size.add_argument('--table-sel', choices=['bpsk', 'qpsk'],
                      help='shorthand for a full table: bpsk 262144 words '
                           '(512 KB, 4096 frames), qpsk 32768 words '
                           '(64 KB, 512 frames)')
    size.add_argument('--words', type=parse_count, metavar='N',
                      help='word count (u16), a multiple of %d (2 KB), max '
                           '262144; accepts a K/M/G suffix, e.g. 256K'
                           % (UNIT_BYTES // 2))
    size.add_argument('--bytes', type=parse_count, metavar='N',
                      help='file size in bytes, a multiple of %d (2 KB), max '
                           '524288 = 512 KB; accepts a K/M/G suffix, e.g. 256K'
                           % UNIT_BYTES)

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

    n_bytes = n_words * 2
    if n_bytes % UNIT_BYTES:
        ap.error('size must be a multiple of 2 KB (%d bytes = %d frames = %d odd '
                 '+ %d even): %d bytes is %d frames and %.1f bytes into the next '
                 'one, which would leave a half frame at the end and shift the '
                 'odd/even phase of everything after it'
                 % (UNIT_BYTES, FRAMES_PER_UNIT, FRAMES_PER_UNIT // 2,
                    FRAMES_PER_UNIT // 2, n_bytes, n_bytes // FRAME_BYTES,
                    n_bytes % FRAME_BYTES))

    seed = args.seed
    if seed is None:
        seed = random.SystemRandom().getrandbits(32)

    rnd = random.Random(seed)
    words = array.array('H', (rnd.getrandbits(16) for _ in range(n_words)))

    # Stamped on the logical values, before any byteswap: after a swap the
    # array no longer holds the value that will be read back out of the RAM.
    stamp_frames(words)
    first8 = list(words[:8])
    headers = (frame_header(words, 0), frame_header(words, 1))
    n_frames = n_words // FRAME_WORDS

    if sys.byteorder != 'little':
        words.byteswap()

    with open(args.out, 'wb') as f:
        f.write(words.tobytes())

    print('=== framed symbol table -> %s ===' % args.out)
    print('source  : %s' % source)
    print('words   : %d (%.1f Kbit)' % (n_words, n_words * 16 / 1024.0))
    print('bytes   : %d' % n_bytes)
    print('frames  : %d x %d bit (%d odd + %d even, odd first)'
          % (n_frames, FRAME_BITS, (n_frames + 1) // 2, n_frames // 2))
    print('header  : %d bit at bit 1..%d, payload %d..%d random'
          % (SYNC_BITS, SYNC_BITS, SYNC_BITS + 1, FRAME_BITS))
    print('sync    : frame 0 = %s (odd), frame 1 = %s (even)'
          % (headers[0], headers[1]))
    print('seed    : 0x%08X   (pass --seed 0x%08X to reproduce)' % (seed, seed))
    print('first 8 : ' + ' '.join('0x%04X' % w for w in first8))
    full = sorted(name for name, w in RAM_TABLE_WORDS.items() if w == n_words)
    if full:
        print('table   : exactly a full %s table' % '/'.join(full))
    else:
        print('note    : not a full table -- tx_ram_configure.py will zero-pad '
              'the rest, and zero words are not valid frames')


if __name__ == '__main__':
    main()
