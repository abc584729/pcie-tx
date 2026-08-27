#!/usr/bin/env python3
"""
Extract stimulus and expected-output data from the HDL Coder generated
testbench hdlsrc/anti_imaging_filter_8/filter_tb.v and write them as
hex files for $readmemh playback in tb_filter8_par_matlab.v.

Outputs (relative to this script):
  data/filter_in_stim.hex        (3172 samples)
  data/filter_out_expected.hex   (25376 = 8 * 3172 samples)
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "..", "hdlsrc", "anti_imaging_filter_8", "filter_tb.v")
OUTDIR = os.path.join(HERE, "data")

N_IN = 3172
N_OUT = 25376

def extract(name, text):
    pat = re.compile(
        r"%s\[\s*(\d+)\]\s*<=\s*16'h([0-9a-fA-F]{4})\s*;" % name)
    pairs = [(int(m.group(1)), m.group(2).upper())
             for m in pat.finditer(text)]
    pairs.sort()
    idx = [i for i, _ in pairs]
    assert idx == list(range(len(idx))), "gap in %s indexes" % name
    return [v for _, v in pairs]


def main():
    with open(SRC) as f:
        text = f.read()

    stim = extract("filter_in_data_log_force", text)
    expc = extract("filter_out_expected", text)

    assert len(stim) == N_IN, "stim count %d != %d" % (len(stim), N_IN)
    assert len(expc) == N_OUT, "expected count %d != %d" % (len(expc), N_OUT)
    assert len(expc) == 8 * len(stim)

    os.makedirs(OUTDIR, exist_ok=True)
    with open(os.path.join(OUTDIR, "filter_in_stim.hex"), "w") as f:
        f.write("\n".join(stim) + "\n")
    with open(os.path.join(OUTDIR, "filter_out_expected.hex"), "w") as f:
        f.write("\n".join(expc) + "\n")

    print("filter_in_stim.hex      : %d samples (first %s last %s)"
          % (len(stim), stim[0], stim[-1]))
    print("filter_out_expected.hex : %d samples (first %s last %s)"
          % (len(expc), expc[0], expc[-1]))


if __name__ == "__main__":
    main()