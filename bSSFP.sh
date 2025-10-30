#! /usr/bin/bash
export SAVE_FILENAME="./data.csv"
make
./bart sim \
	--ODE \
	--seq BSSFP,TR=0.0045,TE=0.00225,Nrep=30,ipl=0,ppl=0.00225,Trf=0.001,FA=45,BWTP=4 \
	-1 3:3:1 \
	-2 1:1:1 \
	./data/simu
