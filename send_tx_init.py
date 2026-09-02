#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
send_tx_init.py — 按 adhocSoft.c //20260902 edit (case 133, initialization setting)
逻辑向节点发送 UDP "初始化设置" 命令包。

case 133 解析格式（UDP 载荷即裸 pBuf，Ethernet 控制口无帧头/无 CRC）：

    偏移      字段                      类型
    ---------------------------------------------
    0         command = 133            u8
    1         ctrl_bpsk                u8 (0/1 enable)
    2..9      fre_bpsk   (dds_f)       double(8B, 小端 IEEE-754, MHz)
    10..17    atten_bpsk (attenuation) double(8B, 小端 IEEE-754, dB)
    18        ctrl_qpsk                u8 (0/1 enable)
    19..26    fre_qpsk   (dds_f)       double(8B, MHz)
    27..34    atten_qpsk (attenuation) double(8B, dB)

    总长 35 字节。

    ARM(Zynq) 为小端，C 侧用 memcpy(&double, &pBuf[off], 8) 原样拷贝，
    因此发包时 double 用 '<d'（小端 IEEE-754）打包。

    目标: 节点控制口 UDP 192.168.1.10:14147（adhocCtrl 监听端口，见 adhocSoft.c）。

用法示例:
    python3 send_tx_init.py                                   # 默认值(同 tx_init)
    python3 send_tx_init.py --ip 192.168.1.10 --port 14147 \
        --bpsk-en 1 --bpsk-freq 100 --bpsk-atten 6 \
        --qpsk-en 1 --qpsk-freq 200 --qpsk-atten 0
    python3 send_tx_init.py --dry-run                          # 只打印打包结果，不发
"""

import argparse
import socket
import struct

CMD_INIT_SETTING = 133

OFF_FRE_BPSK = 2
OFF_ATTEN_BPSK = 10
OFF_FRE_QPSK = 19
OFF_ATTEN_QPSK = 27

# 与 pcie_tx.c tx_init() 的默认一致，便于"裸跑 = 恢复默认初始化"
DEF_CTRL = 1
DEF_FRE_BPSK = 100.0   # MHz
DEF_FRE_QPSK = 200.0   # MHz
DEF_ATTEN = 0.0        # dB


def build_packet(ctrl_bpsk, fre_bpsk, atten_bpsk,
                 ctrl_qpsk, fre_qpsk, atten_qpsk):
    """按 case 133 布局打包，返回 bytes(35)。"""
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
        description='向节点发送 //20260902 case 133 初始化设置命令包')
    ap.add_argument('--ip', default='192.168.1.10', help='节点 IP (默认 192.168.1.10)')
    ap.add_argument('--port', type=int, default=14147, help='节点控制口 (默认 14147)')
    ap.add_argument('--bpsk-en', type=int, default=DEF_CTRL, help='BPSK enable 0/1 (默认 %d)' % DEF_CTRL)
    ap.add_argument('--bpsk-freq', type=float, default=DEF_FRE_BPSK, help='BPSK DDS 频率 MHz (默认 %g)' % DEF_FRE_BPSK)
    ap.add_argument('--bpsk-atten', type=float, default=DEF_ATTEN, help='BPSK 衰减 dB (默认 %g)' % DEF_ATTEN)
    ap.add_argument('--qpsk-en', type=int, default=DEF_CTRL, help='QPSK enable 0/1 (默认 %d)' % DEF_CTRL)
    ap.add_argument('--qpsk-freq', type=float, default=DEF_FRE_QPSK, help='QPSK DDS 频率 MHz (默认 %g)' % DEF_FRE_QPSK)
    ap.add_argument('--qpsk-atten', type=float, default=DEF_ATTEN, help='QPSK 衰减 dB (默认 %g)' % DEF_ATTEN)
    ap.add_argument('--dry-run', action='store_true', help='只打包/打印，不发送')
    args = ap.parse_args()

    pkt = build_packet(args.bpsk_en, args.bpsk_freq, args.bpsk_atten,
                       args.qpsk_en, args.qpsk_freq, args.qpsk_atten)

    print('=== case 133 initialization setting 包 (len=%d) ===' % len(pkt))
    print('cmd     : %d' % pkt[0])
    print('BPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.bpsk_en, args.bpsk_freq, args.bpsk_atten))
    print('QPSK    : enable=%d  dds_f=%.6f MHz  attenuation=%.6f dB'
          % (args.qpsk_en, args.qpsk_freq, args.qpsk_atten))
    print(hex_dump(pkt))

    if args.dry_run:
        print('--dry-run: 未发送。')
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
