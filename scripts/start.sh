#!/bin/bash
set -e
cd ~/scripts

# start mapd
echo "Start MAPD"
cmd="nohup ./start_mapd.sh"
$cmd &disown

# load data
if [ "$1" == load_churn ]; then
   echo "Wait for mapd to start"
   sleep 10
   ~/scripts/create_churn_table.sh
fi
   

source activate pycudf_notebook_py35
cd ~/pygdf
# add pygdf to path
conda develop .
cd notebooks
jupyter notebook --ip=*

