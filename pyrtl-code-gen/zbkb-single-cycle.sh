#! /bin/sh

./ctrl-gen-runner.rkt \
    -r pc \
    -m imem \
    -m dmem \
    -m rf \
    ../hw/out/zbkb-single-cycle.rkt \
    ../spec/zbkb-ila.rkt \
    ../spec/zbkb-decode.rkt > zbkb-single-cycle.py

