echo "==================="
echo "Two-stage core, RVI"
echo "==================="
time ./rv-runner.sh rvi 2 ../hw/out/rvi-2-stage.rkt ../spec/rvi-ila.rkt

echo "=========================="
echo "Two-stage core, RVI + Zbkb"
echo "=========================="
time ./rv-runner.sh zbkb 2 ../hw/out/zbkb-2-stage.rkt ../spec/zbkb-ila.rkt

echo "=========================="
echo "Two-stage core, RVI + Zbkc"
echo "=========================="
time ./rv-runner.sh zbkc 2 ../hw/out/zbkc-2-stage.rkt ../spec/zbkc-ila.rkt

