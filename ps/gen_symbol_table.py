#!/usr/bin/env python3
"""
gen_symbol_table.py
Generate a random symbol table file: 65536 bytes, little-endian u16 =
exactly the 32768 words the TX symbol RAM holds, every word an independent
uniform 16-bit value.

Nothing here knows about modulation. The file is just 32768 numbers; which
table it goes into is decided by send_symbol_table.py --table-sel, and what
the numbers mean once they are in the RAM is the RTL's business.

The seed is printed so a table can be reproduced later with --seed; without
--seed one is drawn from the system entropy pool.

Examples:
    python gen_symbol_table.py -o symbols.bin
    python gen_symbol_table.py -o /tmp/symbols.bin --seed 0xC0FFEE
"""

import argparse
import os
import random
import struct

RAM_TABLE_WORDS = 32768
RAM_TABLE_BYTES = RAM_TABLE_WORDS * 2


def main():
    ap = argparse.ArgumentParser(
        description='Generate a random symbol table file (.bin) for the TX '
                    'symbol RAM')
    ap.add_argument('-o', '--out', metavar='FILE', required=True,
                    help='output file; must end in .bin (%d bytes, '
                         'little-endian u16)' % RAM_TABLE_BYTES)
    ap.add_argument('--seed', type=lambda s: int(s, 0),
                    help='random seed, to make the table reproducible '
                         '(default: drawn from system entropy)')
    args = ap.parse_args()

    if os.path.splitext(args.out)[1].lower() != '.bin':
        raise SystemExit('output must be a .bin file: send_symbol_table.py '
                         'reads .bin only')

    seed = args.seed
    if seed is None:
        seed = random.SystemRandom().getrandbits(32)

    rnd = random.Random(seed)
    words = [rnd.getrandbits(16) for _ in range(RAM_TABLE_WORDS)]

    with open(args.out, 'wb') as f:
        f.write(struct.pack('<%dH' % RAM_TABLE_WORDS, *words))

    print('=== random symbol table -> %s ===' % args.out)
    print('seed    : 0x%08X   (pass --seed 0x%08X to reproduce)' % (seed, seed))
    print('words   : %d (%.1f Kbit)'
          % (RAM_TABLE_WORDS, RAM_TABLE_WORDS * 16 / 1024.0))
    print('bytes   : %d' % RAM_TABLE_BYTES)
    print('first 8 : ' + ' '.join('0x%04X' % w for w in words[:8]))


if __name__ == '__main__':
    main()
