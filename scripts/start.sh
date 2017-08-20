#!/bin/bash
set -e

######################################
#           Default args             #
######################################
LOAD_DATA=NO
JUPYTER_ARGS="--ip=*"

######################################
#           Pars args                #
######################################
for i in "$@"
do
case $i in
    -j=*|--jupyter-args=*)
    JUPYTER_ARGS="${i#*=}"
    shift 
    ;;
    --load-data)
    LOAD_DATA=YES
    shift 
    ;;
    *)  
        echo "unknown option: $i"    
        exit 1
    ;;
esac
done
echo "JUPYTER ARGS    = ${JUPYTER_ARGS}"
echo "LOAD DATA       = ${LOAD_DATA}"

######################################
#            start mapd              #
######################################
cd ~/scripts
echo "Start MAPD"
cmd="nohup ./start_mapd.sh"
$cmd &disown

# load data
if [ $LOAD_DATA == YES ]; then
   echo "Wait for mapd to start"
   sleep 10
   ~/scripts/create_churn_table.sh
fi
   

######################################
#            start Jupyter           #
######################################
source activate pycudf_notebook_py35
cd ~/pygdf
# add pygdf to path
conda develop .
cd ~/notebooks
jupyter notebook $JUPYTER_ARGS 

