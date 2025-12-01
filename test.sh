#! /usr/bin/bash

ARR=(1 2 3 4 5 6 7 8 9 10)

for i in ${ARR[@]:0:5}; do
	echo $i
done

echo "and"

for i in ${ARR[@]:5:10}; do
	echo $i
done