#! /usr/bin/bash
#make

# Note: To make the filenames better readable, we replace floating point dot by underscore
# See: https://stackoverflow.com/questions/54964666/bash-shell-reworking-variable-replace-dots-by-underscore

rm -rf data/*

T1s=$(seq 1 0.5 3)
T2s=$(seq 0.05 0.2 1)
slices=$(seq 0 0.003 0.006)
slgrads=$(seq 0.001 0.002 0.004)

for T1 in $T1s; do
	for T2 in $T2s; do
		for z in $slices; do
			for slg in $slgrads; do
				export T1_1=$T1
				export T2_1=$T2
				export DATA_FILENAME="./data/bssfp-t1_${T1_1//./_}-t2_${T2_1//./_}-slice_${z//./_}-grad_${slg//./_}"
				export SAVE_FILENAME="${DATA_FILENAME}.csv"
				export M0_1=1

				echo $DATA_FILENAME

				./bart sim \
					--ODE \
					--seq BSSFP,TR=0.0045,TE=0.00225,Nrep=300,ipl=0,ppl=0.00225,Trf=0.001,FA=45,BWTP=4,slice-thickness=$z,sl-grad=$slg \
					-1 ${T1_1}:${T1_1}:1 \
					-2 ${T2_1}:${T2_1}:1 \
					./data/simu
				jq -n env > ${DATA_FILENAME}.json
			done
		done
	done
done

VAL_COUNT=10
TEST_COUNT=10
TEST_VAL_FILES=($(ls data | grep .csv | shuf -n $(($VAL_COUNT + $TEST_COUNT))))

mkdir -p data/val
for file in ${TEST_VAL_FILES[@]:0:$VAL_COUNT}; do
	mv data/$file data/val/
	mv data/${file/csv/json} data/val/
done

mkdir -p data/test
for file in ${TEST_VAL_FILES[@]:$VAL_COUNT:$(($VAL_COUNT + $TEST_COUNT))}; do
	mv data/$file data/test/
	mv data/${file/csv/json} data/test/
done

mkdir -p data/train
mv data/*.csv data/train/
mv data/*.json data/train/