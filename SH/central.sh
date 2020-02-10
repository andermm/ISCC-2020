#!/bin/bash
BASE=/home/iscc/ISCC-2020

## Start the script through SSH.
ssh -n -f iscc@iscc.westus.cloudapp.azure.com "sh -c 'cd $BASE; nohup ./SH/experiments_exec.sh > $HOME/apps_std_out.log 2>&1 &'"
#ssh -n -f iscc@104.210.43.32 "sh -c 'cd $BASE; nohup ./SH/experiments_exec.sh > $HOME/apps_std_out.log 2>&1 &'"
