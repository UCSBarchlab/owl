#! /bin/sh

./runner.rkt \
    -r ciphertext \
    -r round_key \
    -r round \
    -s 1 \
    -f 1 \
    -i full \
    ../hw/out/aes.rkt \
    ../spec/aes.rkt
