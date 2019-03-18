#!/bin/bash

ROOT_DIR=$1
MRSS=0

for i in `ls ${ROOT_DIR}`; do
    mkdir -p ${ROOT_DIR}/$i/combined_data
    for j in `ls ${ROOT_DIR}/$i`;do
        if [ "$j" != "combined_data" ]; then
            touch ${ROOT_DIR}/$i/combined_data/$j.txt
        fi
        for k in `ls ${ROOT_DIR}/$i/$j`; do
            for l in `ls ${ROOT_DIR}/$i/$j/$k`; do
                echo $i"/"$j"/"$k"/"$l

                if [ "$k" == "javascript" ]; then
                    mv ${ROOT_DIR}/$i/$j/$k/$l/go.txt ${ROOT_DIR}/$i/$j/$k/$l/$k.txt
                fi
                
                MRSS=$(grep -w "Maximum resident set size" ${ROOT_DIR}/$i/$j/$k/$l/$k.txt | awk -F":" '{print $2}')
                VCS=$(grep -w "Voluntary context switches" ${ROOT_DIR}/$i/$j/$k/$l/$k.txt | awk -F":" '{print $2}')
                MPF=$(grep -w "Minor (reclaiming a frame) page faults" ${ROOT_DIR}/$i/$j/$k/$l/$k.txt | awk -F":" '{print $2}')
                echo "PL:$k,IPC:$l,MRSS:${MRSS},VCS:${VCS},MPF:${MPF}" >> ${ROOT_DIR}/$i/combined_data/$j.txt
            done      
        done
    done
done

echo "Done with each experiment. Combining data..."

languages="csharp go java javascript php python ruby"
ipc="grpc rest rpc"
type=$2

mkdir -p ${ROOT_DIR}/all_results/${type}/MRSS
mkdir -p ${ROOT_DIR}/all_results/${type}/VCS
mkdir -p ${ROOT_DIR}/all_results/${type}/MPF

touch ${ROOT_DIR}/all_results/${type}/MRSS/grpc.txt
touch ${ROOT_DIR}/all_results/${type}/MRSS/rpc.txt
touch ${ROOT_DIR}/all_results/${type}/MRSS/rest.txt

touch ${ROOT_DIR}/all_results/${type}/VCS/grpc.txt
touch ${ROOT_DIR}/all_results/${type}/VCS/rpc.txt
touch ${ROOT_DIR}/all_results/${type}/VCS/rest.txt

touch ${ROOT_DIR}/all_results/${type}/MPF/grpc.txt
touch ${ROOT_DIR}/all_results/${type}/MPF/rpc.txt
touch ${ROOT_DIR}/all_results/${type}/MPF/rest.txt


results_mrss=""
results_vcs=""
results_mpf=""


for i in `ls ${ROOT_DIR}`; do
    if [ "$i" != "all_results" ]; then
    for scenario in ${ipc}; do
        for pl in ${languages}; do
            mrss=""
            vcs=""
            mpf=""

			if [ "${pl}" == "java" -a "$scenario" == "rpc" ]; then
				mrss=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w jax_ws_rpc | grep MRSS | awk -F "," '{print $3}' | awk -F":" '{print $2}')
			    vcs=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w jax_ws_rpc | grep VCS | awk -F "," '{print $4}' | awk -F":" '{print $2}')
                mpf=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w jax_ws_rpc | grep MPF | awk -F "," '{print $5}' | awk -F":" '{print $2}')
            else	
				mrss=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w ${scenario} | grep MRSS | awk -F "," '{print $3}' | awk -F":" '{print $2}')
                vcs=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w ${scenario} | grep VCS | awk -F "," '{print $4}' | awk -F":" '{print $2}')
                mpf=$(grep -w ${pl} ${ROOT_DIR}/$i/combined_data/resource_usage_${type}.txt | grep -w ${scenario} | grep MPF | awk -F "," '{print $5}' | awk -F":" '{print $2}')
            fi

			if [ "${mrss}" == "" ]; then
				mrss="0"
			fi

            if [ "${vcs}" == "" ]; then
				vcs="0"
			fi

            if [ "${mpf}" == "" ]; then
				mpf="0"
			fi

            results_mrss=$(echo "${results_mrss}     ${mrss}")
            results_vcs=$(echo "${results_vcs}     ${vcs}")
            results_mpf=$(echo "${results_mpf}     ${mpf}")
        done
        echo ${results_mrss} >> ${ROOT_DIR}/all_results/${type}/MRSS/${scenario}.txt
        results_mrss=""
        echo ${results_vcs} >> ${ROOT_DIR}/all_results/${type}/VCS/${scenario}.txt
        results_vcs=""
        echo ${results_mpf} >> ${ROOT_DIR}/all_results/${type}/MPF/${scenario}.txt
        results_mpf=""
    done
    fi
done

echo Done
exit