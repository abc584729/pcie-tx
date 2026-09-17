#!/usr/bin/env python3
"""
send_tx_init.py
Send the UDP "initialization setting" command packet to a node,
packed according to case 133 of the //20260902 edit in adhocSoft.c.

case 133 payload layout (UDP payload == raw pBuf; the Ethernet control
socket has no frame header and no CRC):

    offset   field                      type
    ---------------------------------------------
    0        command = 133              u8
    1        ctrl_bpsk                  u8 (0/1 enable)
    2..9     fre_bpsk   (dds_f)         double (8B, little-endian IEEE-754, MHz)
    10..17   atten_bpsk (attenuation)   double (8B, little-endian IEEE-754, dB)
    18       ctrl_qpsk                  u8 (0/1 enable)
    19..26   fre_qpsk   (dds_f)         double (8B, MHz)
    27..34   atten_qpsk (attenuation)   double (8B, dB)
    35       rate_sel                   u8 (0 = bpsk 450k / qpsk 4.5M,
                                           1 = bpsk 400k / qpsk 6.667M)
    36       bpsk_single_shot           u8 (0 = cyclic, 1 = single shot)
    37..44   bpsk_size_kb               double (8B, little-endian IEEE-754)
                                       size of the symbol-table data file, in
                                       kB (1024-based, like the K/M/G suffixes
                                       of gen_symbol_table.py)

    Total length = 45 bytes.

    bpsk_size_kb is the size of the .bin that was uploaded with case 134, so
    "send exactly what I just uploaded" needs no arithmetic on the host side.
    adhocSoft.c converts it to a symbol count: BPSK carries 1 bit per symbol,
    so bits = kB * 1024 * 8 = kB * 8192. The full 512 kB table is therefore
    4194304 bits = 4194304 symbols, which is exactly one pass over the RAM.
    A size of 0 sends nothing; the 23-bit symbol counter caps it at ~1024 kB.

    The ARM (Zynq) is little-endian and the C side copies the double with
    memcpy(&double, &pBuf[off], 8), so each double is packed with '<d'.

    The packet grew in two steps and adhocSoft.c case 133 keeps accepting the
    shorter forms, defaulting each missing trailing field:

        <= 35 bytes  rate_sel = 0
        <  45 bytes  bpsk_single_shot = 0, bpsk_size_kb = 0  (cyclic)

    so the 35- and 36-byte packets still work.

    Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
    listening port, see adhocSoft.c).

Examples:
    cd /d
    python send_tx_init.py --ip 192.168.1.10 --bpsk-en 1 --bpsk-freq 100 --bpsk-atten 0 --bpsk-en 1 --qpsk-en 1 --qpsk-freq 200 --bpsk-atten 0
    python send_tx_init.py --rate 1
    python send_tx_init.py --single 1 --size 256        # the 256 kB file just uploaded
    python send_tx_init.py --single 1 --size full       # whole 512 kB table
    python send_tx_init.py --single 1 --size 1.953125   # a 2000-byte file
    python send_tx_init.py --single 0                   # back to cyclic
"""

import argparse
import socket
import struct

CMD_INIT_SETTING = 133

OFF_FRE_BPSK = 2
OFF_ATTEN_BPSK = 10
OFF_FRE_QPSK = 19
OFF_ATTEN_QPSK = 27
OFF_RATE_SEL = 35
OFF_SINGLE_SHOT = 36
OFF_SIZE_KB = 37

PKT_LEN = 45            # 36 up to rate_sel, +1 single_shot, +8 size_kb

# The symbol table is 262144 x 16 bit = 512 kB of file = 2^22 bit = 2^22 symbols
TABLE_KB = 512.0        # one full pass over the BPSK table
BITS_PER_KB = 1024 * 8  # BPSK: 1 bit per symbol, so bits == symbols
SIZE_KB_MAX = ((1 << 23) - 1) / float(BITS_PER_KB)   # 23-bit counter, ~1024 kB

# Match pcie_tx.c tx_init() defaults, so running bare = restore default init
DEF_CTRL = 1
DEF_FRE_BPSK = 100.0   # MHz
DEF_FRE_QPSK = 200.0   # MHz
DEF_ATTEN = 0.0        # dB
DEF_RATE = 0           # 0 = bpsk 450k / qpsk 4.5M
DEF_SINGLE = 0         # 0 = cyclic (bpsk_size_kb is a don't-care then)
DEF_SIZE_KB = 0.0      # 0 = send nothing in single-shot mode

# rate_sel -> (bpsk, qpsk) symbol rate, for the printout only
RATE_SEL_LABEL = {
    0: ('450 kHz', '4.5 MHz'),
    1: ('400 kHz', '6.667 MHz'),
}


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


def build_packet(ctrl_bpsk, fre_bpsk, atten_bpsk,
                 ctrl_qpsk, fre_qpsk, atten_qpsk, rate_sel,
                 single_shot, size_kb):
    """Pack the payload per the case 133 layout; return bytes(45)."""
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_INIT_SETTING
    buf[1] = int(ctrl_bpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_BPSK, float(fre_bpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_BPSK, float(atten_bpsk))
    buf[18] = int(ctrl_qpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_QPSK, float(fre_qpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_QPSK, float(atten_qpsk))
    buf[OFF_RATE_SEL] = int(rate_sel) & 0x1
    buf[OFF_SINGLE_SHOT] = int(single_shot) & 0x1
    struct.pack_into('<d', buf, OFF_SIZE_KB, float(size_kb))
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
        description='Send the //20260902 case 133 initialization-setting command')
    ap.add_argument('--ip', default='192.168.1.10', help='node IP (default 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='node ctrl port (default 14147)')
    ap.add_argument('--bpsk-en', type=int, default=DEF_CTRL, help='BPSK enable 0/1 (default %d)' % DEF_CTRL)
    ap.add_argument('--bpsk-freq', type=float, default=DEF_FRE_BPSK, help='BPSK DDS freq MHz (default %g)' % DEF_FRE_BPSK)
    ap.add_argument('--bpsk-atten', type=float, default=DEF_ATTEN, help='BPSK attenuation dB (default %g)' % DEF_ATTEN)
    ap.add_argument('--qpsk-en', type=int, default=DEF_CTRL, help='QPSK enable 0/1 (default %d)' % DEF_CTRL)
    ap.add_argument('--qpsk-freq', type=float, default=DEF_FRE_QPSK, help='QPSK DDS freq MHz (default %g)' % DEF_FRE_QPSK)
    ap.add_argument('--qpsk-atten', type=float, default=DEF_ATTEN, help='QPSK attenuation dB (default %g)' % DEF_ATTEN)
    ap.add_argument('--rate', type=int, default=DEF_RATE, choices=(0, 1),
                    help='symbol rate select: 0 = bpsk 450k/qpsk 4.5M, '
                         '1 = bpsk 400k/qpsk 6.667M (default %d)' % DEF_RATE)
    ap.add_argument('--single', type=int, default=DEF_SINGLE, choices=(0, 1),
                    help='BPSK mode: 0 = cyclic, 1 = single shot (default %d)' % DEF_SINGLE)
    ap.add_argument('--size', default=str(DEF_SIZE_KB),
                    help='size of the uploaded symbol-table file, in kB (1024-based, '
                         'K/M suffix ok) or "full" for the whole %g kB table; '
                         'default %g' % (TABLE_KB, DEF_SIZE_KB))
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    size_kb = parse_size_kb(args.size)

    pkt = build_packet(args.bpsk_en, args.bpsk_freq, args.bpsk_atten,
                       args.qpsk_en, args.qpsk_freq, args.qpsk_atten,
                       args.rate, args.single, size_kb)

    rate_sel = pkt[OFF_RATE_SEL]
    bpsk_rate, qpsk_rate = RATE_SEL_LABEL[rate_sel]

    # what adhocSoft.c will make of it: BPSK is 1 bit per symbol
    sym_num = int(size_kb * BITS_PER_KB + 0.5)

    if not pkt[OFF_SINGLE_SHOT]:
        burst = 'cyclic, --size ignored'
    elif sym_num == 0:
        burst = 'single shot, sends nothing'
    else:
        rs = 450e3 if rate_sel == 0 else 400e3   # bpsk symbol rate
        burst = 'single shot, %.6f s (%d symbols at %s)' % (sym_num / rs, sym_num, bpsk_rate)
        if sym_num > TABLE_KB * BITS_PER_KB:
            burst += ' [longer than the table, it repeats]'

    print('=== case 133 initialization setting pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('BPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.bpsk_en, args.bpsk_freq, args.bpsk_atten))
    print('QPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.qpsk_en, args.qpsk_freq, args.qpsk_atten))
    print('rate_sel: %d  (bpsk %s / qpsk %s)' % (rate_sel, bpsk_rate, qpsk_rate))
    print('burst   : single_shot=%d  size=%.6f kB (%d bytes) -> %d bits'
          % (pkt[OFF_SINGLE_SHOT], size_kb, int(round(size_kb * 1024)), sym_num))
    print('          %s' % burst)
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
