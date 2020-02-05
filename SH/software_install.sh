#2 - Install the dependencies
nome=(gfortran openmpi-bin libopenmpi-dev)
for (( n = 0; n < 3; n++ )); do
	packets=$(dpkg --get-selections | grep ${nome[n]})
	if [ -n "$packets" ];
	then
		echo All necessary packets are installed!
	else
		sudo apt install ${nome[n]} -y
	fi
done
