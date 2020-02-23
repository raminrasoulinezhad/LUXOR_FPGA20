#!/bin/bash

ERR_CODE=100

display_usage() {
    echo -e "$0 Supported options:"
    echo -e "\t-g = GPC sets to use, comma-separated. default: none. options:"
    echo -e "\t\tx = xilinx baseline"
    echo -e "\t\tx_l = x-luxor"
    echo -e "\t\tx_lp = x-luxor+"
    echo -e "\t\ti = intel baseline"
    echo -e "\t\ti_l = i-luxor"
    echo -e "\t\ti_lp = i-luxor+"
    echo -e "\t-f = CSV file of benchmarks to run. default: tests/all_tests.csv"
    echo -e "\t-h = prints this help"
}

if [ "$#" -eq 0 ]
then
    display_usage
    exit $ERR_CODE
fi

# defaults
x=0
i=0
x_l=0
x_lp=0
i_l=0
i_lp=0
file_tests="tests/all_tests.csv"
gpcs=z

parse_gpcs() {
    if [ $gpcs == "z" ]
    then
        echo "GPC set must be specified. Use -h to see help options."
        exit $ERR_CODE
    fi
    num_fields=`echo $1 | sed "s/,/\n/g" | wc -l`
    for (( j=1;j<=$num_fields;j++ ))
    do
        val=`echo $1 | cut -d"," -f$j`
        case $val in
            x)
                x=1
                ;;
            x_l)
                x_l=1
                ;;
            x_lp)
                x_lp=1
                ;;
            i)
                i=1
                ;;
            i_l)
                i_l=1
                ;;
            i_lp)
                i_lp=1
                ;;
            *)
                echo "Invalid GPC set provided = $val"
                exit $ERR_CODE
        esac
    done
}

while getopts "g:f:h:" OPTION; do
    case $OPTION in
        g)
            gpcs=$OPTARG
            ;;
        f)
            file_tests=$OPTARG
            ;;
        h)
            display_usage
            exit 0
            ;;
        *)
            echo "Invalid arg provided = $OPTION"
            exit $ERR_CODE
            ;;
    esac
done

parse_gpcs $gpcs

######################## Experiments ############################

MAX_STAGES=10 # empirically determined; all benchmarks were feasible within this limit
I_HEURISTIC=10000 # large integer to enforce binary constraint (see Kumm/Zipf paper)
L_HEURISTIC=10000 # large integer to encourage solver to find solution with smallest delay/stages (see Kumm/Zipf paper)

if [ $x -eq 1 ]
then
    # Xilinx-baseline
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Xilinx/Baseline.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=xilinx \
        --expr_name='Xilinx_Baseline' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

if [ $x_l -eq 1 ]
then
    # X-LUXOR
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Xilinx/LUXOR.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=xilinx \
        --expr_name='X_LUXOR' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

if [ $x_lp -eq 1 ]
then
    # X-LUXOR+
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Xilinx/LUXOR+.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=xilinx \
        --expr_name='X_LUXOR+' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

if [ $i -eq 1 ]
then
    # Intel-baseline
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Intel/Baseline.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=intel \
        --expr_name='Intel_Baseline' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

if [ $i_l -eq 1 ]
then
    # I-LUXOR
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Intel/LUXOR.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=intel \
        --expr_name='I_LUXOR' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

if [ $i_lp -eq 1 ]
then
    # I-LUXOR+
    python3 model.py \
        --iterate_ds=1 \
        --use_cplex=1 \
        --inputs_file=$file_tests \
        --gpc_file=./GPCs/Intel/LUXOR+.csv \
        --max_stages=$MAX_STAGES \
        --arch_name=intel \
        --expr_name='I_LUXOR+' \
        --i_heuristic=$I_HEURISTIC \
        --l_heuristic=$L_HEURISTIC
fi

