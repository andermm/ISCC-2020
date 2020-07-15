#!/bin/bash

#############################################################################################################
##################################Step 1: Defining the Variables#############################################
#############################################################################################################

#Variable Directories
BASE=$HOME/ISCC-2020
SCRIPTS=$BASE/SH
BENCHMARKS=$BASE/BENCHMARKS
LOGS=$BASE/LOGS
MACHINE_FILE=$BASE/MACHINE_FILES
DoE=$MACHINE_FILES/DoE.R
LOGS_DOWNLOAD=$LOGS/LOGS_DOWNLOAD
LOGS_CSV=$LOGS/LOGS_CSV
LOGS_BACKUP_SRC_CODE=$LOGS/LOGS_BACKUP_SRC_CODE

#NPB Variables
NPBE=NPB3.4
APP_BIN_NPBE=$NPBE/NPB3.4-MPI/bin
APP_CONFIG_NPBE=$NPBE/NPB3.4-MPI/config
APP_COMPILE_NPBE=$NPBE/NPB3.4-MPI

#Alya Exec Variables
ALYAE=alya
ALYAE_DIR=$ALYAE/Executables/unix
APP_BIN_ALYAE=$ALYAE_DIR/Alya.x
APP_CONFIG_ALYAE=$ALYAE/Executables/unix/config.in
APP_ALYAE_TUFAN=$ALYAE/4_tufan_run/c/c
ALYAE_LOG=$APP_ALYAE_TUFAN.log

#Intel MPI Benchmarks Variables
INTEL=mpi-benchmarks
INTEL_SOURCE=$INTEL/src_cpp/Makefile
APP_BIN_INTEL=$INTEL/IMB-MPI1
APP_TEST_INTEL=PingPong

	instance=F8

#Other Variables
START=`date +"%d-%m-%Y.%Hh%Mm%Ss"`
OUTPUT_APPS_EXEC=$LOGS_CSV/exec_$instance.$START.csv
OUTPUT_INTEL_EXEC=$LOGS_CSV/intel_$instance.$START.csv
CONTROL_FILE_OUTPUT=$BASE/LOGS/SYS_INFO/env_info_$instance.org
PARTITION=(isccf8ulz000000 isccf8ulz000002 isccf8ulz000003 isccf8ulz000004 isccf8ulz000005 isccf8ulz000006 isccf8ulz000008 isccf8ulz000009)

#############################################################################################################
#######################Step 2: Create the Folders/Download and Compile the Programs##########################
#############################################################################################################
mkdir -p $BASE/LOGS/SYS_INFO
mkdir -p $BENCHMARKS
mkdir -p $LOGS
mkdir -p $BASE/LOGS/LOGS_BACKUP
mkdir -p $LOGS_DOWNLOAD
mkdir -p $LOGS_CSV
mkdir -p $LOGS_BACKUP_SRC_CODE

#############################################################################################################
#################################Step 3: Collect the System Information######################################
#############################################################################################################

echo "#+TITLE: System Information" >> $CONTROL_FILE_OUTPUT
echo "#+DATE: $(eval date)" >> $CONTROL_FILE_OUTPUT
echo "#+AUTHOR: $(eval whoami)" >> $CONTROL_FILE_OUTPUT
echo "#+MACHINE: $(eval hostname)" >> $CONTROL_FILE_OUTPUT
echo "#+FILE: $(eval basename $CONTROL_FILE_OUTPUT)" >> $CONTROL_FILE_OUTPUT
echo "" >> $CONTROL_FILE_OUTPUT

#Executes the system information collector script
for (( i = 0; i < 8; i++ )); do
	ssh ${PARTITION[i]} '/home/iscc/ISCC-2020/SH/./sys_info_collect.sh'
done


########################################Alya################################################
#Exec
cd $BENCHMARKS
appsa=alya
git clone --recursive --progress https://gitlab.com/ammaliszewski/alya.git 2> $LOGS_DOWNLOAD/Alya_$instance.download.log
cp -r alya $LOGS_BACKUP_SRC_CODE
tar -zcvf $LOGS_BACKUP_SRC_CODE/Alya_$instance.tar.gz $LOGS_BACKUP_SRC_CODE/alya
rm -rf $LOGS_BACKUP_SRC_CODE/alya;
cd $ALYAE_DIR
cp configure.in/config_gfortran.in config.in
sed -i 's,mpif90,mpifort,g' config.in
./configure -x nastin parall
make metis4; make

#######################################NPB##################################################
#Exec
cd $BENCHMARKS
wget -c https://www.nas.nasa.gov/assets/npb/NPB3.4.tar.gz -S -a $LOGS_DOWNLOAD/NPB3.4_$instance.download.log
cp -r NPB3.4.tar.gz $LOGS_BACKUP_SRC_CODE; mv $LOGS_BACKUP_SRC_CODE/NPB3.4.tar.gz $LOGS_BACKUP_SRC_CODE/NPB3.4_$instance.tar.gz
tar -xzf NPB3.4.tar.gz
rm -rf NPB3.4.tar.gz

for f in $APP_CONFIG_NPBE/*.def.template; do
	mv -- "$f" "${f%.def.template}.def"; 
done

sed -i 's,mpif90,mpifort,g' $APP_CONFIG_NPBE/make.def
appsn=(bt ep cg mg sp lu is ft)
classes=(D)
echo -n "" > $APP_CONFIG_NPBE/suite.def

for (( n = 0; n < 8; n++ )); do
	for (( i = 0; i < 1; i++ )); do
		echo -e ${appsn[n]}"\t"${classes[i]} >> $APP_CONFIG_NPBE/suite.def
	done
done
cd $APP_COMPILE_NPBE; make suite


#################################Intel MPI Benchmarks#############################################
cd $BENCHMARKS
appsi=intel
git clone --recursive --progress https://github.com/intel/mpi-benchmarks.git 2> $LOGS_DOWNLOAD/mpi-benchmarks_$instance.download.log
cp -r mpi-benchmarks $LOGS_BACKUP_SRC_CODE
tar -zcvf $LOGS_BACKUP_SRC_CODE/mpi-benchmarks_$instance.tar.gz $LOGS_BACKUP_SRC_CODE/mpi-benchmarks
rm -rf $LOGS_BACKUP_SRC_CODE/mpi-benchmarks
sed -i 's,mpiicc,mpicc,g' $INTEL_SOURCE
sed -i 's,mpiicpc,mpicxx,g' $INTEL_SOURCE
cd $INTEL; make IMB-MPI1
cd $BASE
#############################################################################################################
#######################Step 4: Define the Machine Files and Experimental Project#############################
#############################################################################################################

#Define the machine file and Experimental Project
MACHINEFILE=$MACHINE_FILE/nodes_$instance
MACHINEFILE_INTEL=$MACHINE_FILE/nodes_intel_$instance
PROJECT=$MACHINE_FILE/experimental_project.csv

#############################################################################################################
#######################Step 5: Read the Experimental Project and Started the Execution Loop##################
#############################################################################################################

#Read the experimental project
tail -n +2 $PROJECT |
while IFS=, read -r apps instace number 
do

#Define a single key
	KEY="$number-$apps-$instance"
	echo ""
	echo $KEY
	echo ""

#Prepare the command for execution
	runline=""
	runline+="mpiexec --mca btl self,"
	
#Select interface
		runline+="tcp --mca btl_tcp_if_include eth0 "
#Select app
	if [[ $apps == intel ]]; then
		PROCS=2
		runline+="-np $PROCS -machinefile $MACHINEFILE_INTEL "
		
	else
		PROCS=64
		runline+="-np $PROCS -machinefile $MACHINEFILE "
	fi		
#Save the output according to the app
	if [[ $apps == intel ]]; then
		runline+="$BENCHMARKS/$APP_BIN_INTEL $APP_TEST_INTEL "
		runline+="2>> $LOGS/apps_exec_std_error "
		runline+="&> >(tee -a $LOGS/LOGS_BACKUP/$apps_$instance.log > /tmp/intel_mb.out)"

	elif [[ $apps == alya ]]; then
		runline+="$BENCHMARKS/$APP_BIN_ALYAE BENCHMARKS/$APP_ALYAE_TUFAN "
		runline+="2 >> $LOGS/apps_exec_std_error "
		runline+="&> >(tee -a $LOGS/LOGS_BACKUP/$apps_$instance.log > /tmp/alya.out)"
	
	else
		runline+="$BENCHMARKS/$APP_BIN_NPBE/$apps.D.x "
		runline+="2>> $LOGS/apps_exec_std_error "
		runline+="&> >(tee -a $LOGS/LOGS_BACKUP/$apps_$instance.log > /tmp/nas.out)"	
	fi	

#Execute the experiments
	echo "Executing >> $runline <<"
	eval "$runline < /dev/null"
	
	#Save the output according to the app

	if [[ $apps == intel ]]; then
		N=`tail -n +35 /tmp/intel_mb.out | awk {'print $1'} | grep -v '[^ 0.0-9.0]' | sed '/^[[:space:]]*$/d' | wc -l`
		for (( i = 0; i < $N; i++ )); do
			echo "$apps" >> /tmp/for.out
		done

		tail -n +35 /tmp/intel_mb.out | awk {'print $1'} | grep -v '[^ 0.0-9.0]' | sed '/^[[:space:]]*$/d' > /tmp/BYTES
    	tail -n +35 /tmp/intel_mb.out | awk {'print $3'} | grep -v '[^ 0.0-9.0]' | sed '/^[[:space:]]*$/d' > /tmp/TIME
    	tail -n +35 /tmp/intel_mb.out | awk {'print $4'} | grep -v '[^ 0.0-9.0]' | sed '/^[[:space:]]*$/d' > /tmp/Mbytes
    	paste -d"," /tmp/for.out /tmp/BYTES /tmp/TIME /tmp/Mbytes >> $OUTPUT_INTEL_EXEC
    	rm /tmp/for.out; rm /tmp/BYTES; rm /tmp/TIME; rm /tmp/Mbytes
		
	elif [[ $apps == alya ]]; then
		TIME=`cat $BENCHMARKS/$ALYAE_LOG | grep "TOTAL CPU TIME" | awk '{print $4}'`
		echo "$apps,$TIME" >> $OUTPUT_APPS_EXEC
	
	else
		TIME=`grep -i "Time in seconds" /tmp/nas.out | awk {'print $5'}`
		echo "$apps,$TIME" >> $OUTPUT_APPS_EXEC
	fi

	echo "Done!"

done


sed -i '1s/^/apps,time\n/' $OUTPUT_APPS_EXEC
sed -i '1s/^/apps,bytes,time,mbytes-sec\n/' $OUTPUT_INTEL_EXEC

exit
