#!/bin/bash

appsa=(alya)
appsn=(bt ep cg mg sp lu is ft)
appsi=(intel)

for (( i = 0; i < 30; i++ )); do
	echo $appsa >> /tmp/expd
	echo $appsi >> /tmp/expd
	for (( n = 0; n < 8; n++ )); do
		echo ${appsn[n]} >> /tmp/expd
	done
done

#shuf /tmp/expd -o > /tmp/exp
#awk '{print NR 'sep' $0; sep=","}' /tmp/expd > experiments_design.csv 
#exit