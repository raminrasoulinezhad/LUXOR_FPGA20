#!/bin/bash

# script to check all CSV files are present to build plots

fail=0

for g in Xilinx_Baseline X_LUXOR X_LUXOR+ Intel_Baseline I_LUXOR I_LUXOR+
do
    for i in {0..57}
    do
        fpath="results/${g}_all_tests_$i.csv"
        if [ ! -f $fpath ]
        then
            fail=1
            echo "Missing $fpath"
        fi
    done
done

if [ $fail -eq 1 ]
then
    echo "Error: All data not available for plotting."
    exit $fail
fi

# collect results
ofile="results/all_results.csv"
echo "arch,test_num,cost,stages" > $ofile

for g in Xilinx_Baseline X_LUXOR X_LUXOR+ Intel_Baseline I_LUXOR I_LUXOR+
do
    for i in {0..57}
    do
        fpath="results/${g}_all_tests_$i.csv"
        vals=`cat $fpath | grep -v "cost"`
        echo "$g,$i,$vals" >> $ofile
    done
done

exit 0

