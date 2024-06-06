#!/bin/bash

PRE=cmov
SMT=0
STEPS=3
SKETCH="../hw/out/crypto-core.rkt"
SPEC="../spec/cmov-ila.rkt"
STATE="-r pc -r wb_cont_mem_write -r wb_cont_mem_sign_ext -r decode_pc -r wb_cont_mask_mode -r wb_reg_write_data -r wb_mem_address -r wb_mem_write_data -r instruction_commit -r wb_pc -r wb_rd -r inst_pipelined -r wb_reg_write_enable -r fetch_pc -r if_idex_valid -r wb_cont_mem_read -m imem -m dmem -m rf" 
RESULTS="../results"

while read inst; do
	screen -dmS "$PRE.$inst" bash -c "./runner.rkt -i $inst -t $SMT -s $STEPS $STATE $SKETCH $SPEC &> $RESULTS/$PRE.$STEPS.$inst.out"
done <instructions/"$PRE".in

while true; do
	screen -ls &> /dev/null
	test $? -eq 1 && break
done

grep "unsat" $RESULTS/$PRE.$STEPS.*
