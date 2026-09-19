#!/usr/bin/env python3
"""
tx_configure.py
Send the UDP "configuration" command packet to a node, packed according to
case 133 of the //20260902 edit in adhocSoft.c.

This is the *configure* half of the old send_tx_init.py: it sets the
frequency / attenuation / enable / rate parameters, and -- unlike the burst
parameters -- these are safe to change while transmitting, so case 133 applies
them straight to the hardware (tx_apply_config() in pcie_tx.c). It does not
touch TX_REG_RESET, so the read pointer, symbol counter, `done` and the
timebase all keep running and whatever is on the air is not interrupted.

What case 133 does NOT do is start or restart a burst. Those parameters live
in their own commands, because they have to be written inside the tx_start()
reset window:

    tx_start.py             (case 135)  burst length + mode + start position
                                        in the timebase, then tx_start()

So the order is: tx_configure.py -> tx_ram_configure.py -> tx_start.py.
Run tx_configure.py again at any time to retune -- it takes effect immediately.
tx_start() re-applies the same values at the next tx_start.py, so a start always
comes up from a known state.

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

    Total length = 36 bytes.

    The packet used to run to 47 bytes (bpsk_single_shot, bpsk_size_kb,
    bpsk_time_sel). Those three fields moved to their own command word --
    see tx_start.py (135). case 133 still ignores anything past byte 35, so
    old 45/47-byte packets do no harm, except that their burst/time_sel
    fields are now silently ignored: send a tx_start.py packet instead.

    rate_sel changes both the symbol rate and the truncation in the adders,
    so after switching it you have to re-upload the symbol table (case 134).

    It also changes what a bpsk sub-symbol start offset means: 0x71C
    (clock_sel) is "which clock inside the symbol period", and a symbol is
    400 clocks at 450k but 450 at 400k. case 135 does the split with whatever
    tx_rate_sel is at the time, so switching the rate leaves the old 0x71C
    meaning a different fraction of a symbol -- re-send the tx_start.py packet
    after a --rate change to have it recomputed.

    The ARM (Zynq) is little-endian and the C side copies the double with
    memcpy(&double, &pBuf[off], 8), so each double is packed with '<d'.

    Target: node control port UDP 192.168.1.10:14147 (the adhocCtrl
    listening port, see adhocSoft.c).

Examples:
    cd /d
    python tx_configure.py --ip 192.168.1.10 --bpsk-en 1 --bpsk-freq 100 --bpsk-atten 0 --qpsk-en 1 --qpsk-freq 200 --qpsk-atten 0
    python tx_configure.py --rate 1
    python tx_configure.py --dry-run
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

PKT_LEN = 36            # ends at rate_sel; burst/time_sel moved to case 135

# Match pcie_tx.c tx_start() defaults, so running bare = restore default init
DEF_CTRL = 1
DEF_FRE_BPSK = 100.0   # MHz
DEF_FRE_QPSK = 200.0   # MHz
DEF_ATTEN = 0.0        # dB
DEF_RATE = 0           # 0 = bpsk 450k / qpsk 4.5M

# rate_sel -> (bpsk, qpsk) symbol rate, for the printout only
RATE_SEL_LABEL = {
    0: ('450 kHz', '4.5 MHz'),
    1: ('400 kHz', '6.667 MHz'),
}


def build_packet(ctrl_bpsk, fre_bpsk, atten_bpsk,
                 ctrl_qpsk, fre_qpsk, atten_qpsk, rate_sel):
    """Pack the payload per the case 133 layout; return bytes(36)."""
    buf = bytearray(PKT_LEN)
    buf[0] = CMD_INIT_SETTING
    buf[1] = int(ctrl_bpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_BPSK, float(fre_bpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_BPSK, float(atten_bpsk))
    buf[18] = int(ctrl_qpsk) & 0xFF
    struct.pack_into('<d', buf, OFF_FRE_QPSK, float(fre_qpsk))
    struct.pack_into('<d', buf, OFF_ATTEN_QPSK, float(atten_qpsk))
    buf[OFF_RATE_SEL] = int(rate_sel) & 0x1
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
        description='Send the //20260902 case 133 configuration-setting command '
                    '(frequency / attenuation / enable / rate only -- run '
                    'tx_start.py to actually start transmitting)')
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
                         '1 = bpsk 400k/qpsk 6.667M (default %d); switching it '
                         'needs a case 134 table re-upload and a fresh '
                         'tx_start.py packet (the bpsk sub-symbol start offset '
                         'is counted in clocks, and a symbol is 400 clocks at '
                         '450k but 450 at 400k)' % DEF_RATE)
    ap.add_argument('--dry-run', action='store_true', help='build/print packet only, do not send')
    args = ap.parse_args()

    pkt = build_packet(args.bpsk_en, args.bpsk_freq, args.bpsk_atten,
                       args.qpsk_en, args.qpsk_freq, args.qpsk_atten,
                       args.rate)

    rate_sel = pkt[OFF_RATE_SEL]
    bpsk_rate, qpsk_rate = RATE_SEL_LABEL[rate_sel]

    print('=== case 133 configuration setting pkt (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('BPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.bpsk_en, args.bpsk_freq, args.bpsk_atten))
    print('QPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.qpsk_en, args.qpsk_freq, args.qpsk_atten))
    print('rate_sel: %d  (bpsk %s / qpsk %s)' % (rate_sel, bpsk_rate, qpsk_rate))
    print('note    : applied to the hardware immediately (runtime-safe). '
          'Starts/restarts nothing -- use tx_start.py for that.')
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
