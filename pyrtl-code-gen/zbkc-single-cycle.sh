#! /bin/sh

./ctrl-gen-runner.rkt \
    -r pc \
    -m imem \
    -m dmem \
    -m rf \
    ../hw/out/zbkc-single-cycle.rkt \
    ../spec/zbkc-ila.rkt \
    ../spec/zbkc-decode.rkt > zbkc-single-cycle.py

