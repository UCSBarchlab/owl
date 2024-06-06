#! /bin/sh

./ctrl-gen-runner.rkt \
    -r pc \
    -m imem \
    -m dmem \
    -m rf \
    ../hw/out/rvi-single-cycle.rkt \
    ../spec/rvi-ila.rkt \
    ../spec/rvi-decode.rkt > rvi-single-cycle.py

