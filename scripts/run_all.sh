#!/bin/bash

MAX_STAGES=10 # empirically determined; all benchmarks were feasible within this limit
I_HEURISTIC=10000 # large integer to enforce binary constraint (see Kumm/Zipf paper)
L_HEURISTIC=10000 # large integer to encourage solver to find solution with smallest delay/stages (see Kumm/Zipf paper)

# Xilinx-baseline all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Xilinx/Baseline.csv \
    --max_stages=10 \
    --arch_name=xilinx \
    --expr_name='Xilinx_Baseline' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

exit
# X-LUXOR all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Xilinx/LUXOR.csv \
    --max_stages=10 \
    --arch_name=xilinx \
    --expr_name='X_LUXOR' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

# X-LUXOR+ all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Xilinx/LUXOR+.csv \
    --max_stages=10 \
    --arch_name=xilinx \
    --expr_name='X_LUXOR+' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

# Intel-baseline all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Intel/Baseline.csv \
    --max_stages=10 \
    --arch_name=intel \
    --expr_name='Intel_Baseline' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

# I-LUXOR all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Intel/LUXOR.csv \
    --max_stages=10 \
    --arch_name=intel \
    --expr_name='I_LUXOR' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

# I-LUXOR+ all test cases
python3 model.py \
    --iterate_ds=1 \
    --use_cplex=1 \
    --inputs_file=./tests/all_tests.csv \
    --gpc_file=./GPCs/Intel/LUXOR+.csv \
    --max_stages=10 \
    --arch_name=intel \
    --expr_name='I_LUXOR+' \
    --i_heuristic=$I_HEURISTIC \
    --l_heuristic=$L_HEURISTIC

