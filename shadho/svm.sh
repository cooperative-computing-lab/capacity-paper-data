#!/usr/bin/env bash

module load python
export PYTHONPATH=/afs/crc.nd.edu/user/n/nkremerh/.local/lib/python2.7/site-packages:$PYTHONPATH

export JOBLIB_TEMP_FOLDER="./joblib"
mkdir $JOBLIB_TEMP_FOLDER
python svm.py
rm -r $JOBLIB_TEMP_FOLDER
