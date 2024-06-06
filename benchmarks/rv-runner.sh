#!/bin/bash

PRE=$1
STEPS=$2
SKETCH=$3
SPEC=$4
STATE="-r pc -m imem -m dmem -m rf"
RESULTS="../results"

[ -f instructions/"$PRE".in ] &&
while read inst; do
	screen -dmS "$PRE.$inst" bash -c "./runner.rkt -i $inst -s $STEPS $STATE $SKETCH $SPEC &> $RESULTS/$PRE.$STEPS.$inst.out"
done <instructions/"$PRE".in

[ -f instructions/"$PRE".cvc4.in ] &&
while read inst; do
	screen -dmS "$PRE.$inst" bash -c "./runner.rkt -i $inst -t 1 -s $STEPS $STATE $SKETCH $SPEC &> $RESULTS/$PRE.$STEPS.$inst.out"
done <instructions/"$PRE".cvc4.in

[ -f instructions/"$PRE".z3.in ] &&
while read inst; do
	screen -dmS "$PRE.$inst" bash -c "./runner.rkt -i $inst -t 2 -s $STEPS $STATE $SKETCH $SPEC &> $RESULTS/$PRE.$STEPS.$inst.out"
done <instructions/"$PRE".z3.in

while true; do
	screen -ls &> /dev/null
	test $? -eq 1 && break
done

grep "unsat" $RESULTS/$PRE.$STEPS.*
