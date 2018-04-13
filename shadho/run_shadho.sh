#!/usr/bin/env bash

module load python

if [ ! -d "results" ]; then
    mkdir "results"
fi

python driver.py

condor_rm nkremerh

mv shadho_* shadho.* "results"
