echo "======================"
echo "Single-cycle core, RVI"
echo "======================"
time ./rv-runner.sh rvi 1 ../hw/out/rvi-single-cycle.rkt ../spec/rvi-ila.rkt

echo "============================="
echo "Single-cycle core, RVI + Zbkb"
echo "============================="
time ./rv-runner.sh zbkb 1 ../hw/out/zbkb-single-cycle.rkt ../spec/zbkb-ila.rkt

echo "============================="
echo "Single-cycle core, RVI + Zbkc"
echo "============================="
time ./rv-runner.sh zbkc 1 ../hw/out/zbkc-single-cycle.rkt ../spec/zbkc-ila.rkt

