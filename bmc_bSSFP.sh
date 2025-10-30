#! /usr/bin/bash
export SAVE_FILENAME="./bmc_data.csv"
make
./bart sim \
	--ODE \
	--seq BSSFP,TR=0.0045,TE=0.00225,Nrep=10,ipl=0,ppl=0.00225,Trf=0.001,FA=45,BWTP=4 \
	--BMC \
	--pool P=2,T1=1.048:0:0:0,T2=0.015:0:0:0,M0=0.3:0.3:0.3:0.3,k=10:10:10:10 \
    --T1 1.048:1.048:1 \
    --T2 0.069:0.069:1 \
	./data/simu_bmc
