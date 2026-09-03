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

    Total length = 35 bytes.

    The ARM (Zynq) is little-endian and the C side copies the double with
    memcpy(&double, &pBuf[off], 8), so each double is packed with '<d'.

    Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
    listening port, see adhocSoft.c).

Examples:
    cd /d %USERPROFILE%\Desktops
    python send_tx_init.py --ip 192.168.1.10 --bpsk-en 1 --bpsk-freq 100 --bpsk-atten 0 --bpsk-en 1 --qpsk-en 1 --qpsk-freq 200 --bpsk-atten 0
"""

import argparse
import socket
import struct

CMD_INIT_SETTING = 133

OFF_FRE_BPSK = 2
OFF_ATTEN_BPSK = 10
OFF_FRE_QPSK = 19
OFF_ATTEN_QPSK = 27

# Match pcie_tx.c tx_init() defaults, so running bare = restore default init
DEF_CTRL = 1
DEF_FRE_BPSK = 100.0   # MHz
DEF_FRE_QPSK = 200.0   # MHz
DEF_ATTEN = 0.0        # dB


def build_packet(ctrl_bpsk, fre_bpsk, atten_bpsk,
                 ctrl_qpsk, fre_qpsk, atten_qpsk):
    """Pack the payload per the case 133 layout; return bytes(35)."""
    buf = bytearray(35)
    buf[0] = CMD_INIT_SETTING
    buf[1] = int(ctrl_bpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_BPSK, float(fre_bpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_BPSK, float(atten_bpsk))
    buf[18] = int(ctrl_qpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_QPSK, float(fre_qpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_QPSK, float(atten_qpsk))
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
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    pkt = build_packet(args.bpsk_en, args.bpsk_freq, args.bpsk_atten,
                       args.qpsk_en, args.qpsk_freq, args.qpsk_atten)

    print('=== case 133 initialization setting pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('BPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.bpsk_en, args.bpsk_freq, args.bpsk_atten))
    print('QPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.qpsk_en, args.qpsk_freq, args.qpsk_atten))
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
