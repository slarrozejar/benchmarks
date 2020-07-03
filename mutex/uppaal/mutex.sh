#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

cycle=1
mutex_delay=2

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N cycle mutex_delay";
    echo "       N number of processes";
    echo "       cycle time of a cycle in a node"
    echo "       mutex_delay delay of a mutex control"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 3 ]; then
    N=$1
    cycle=$2
    mutex_delay=$3
else
    usage
    exit 1
fi

# Model
cat mutex.xml | sed -e s/"N = 2"/"N = $N"/ -e s/"cycle = 1"/"cycle = $cycle"/ -e s/"mutex_delay = 2"/"mutex_delay = $mutex_delay"/ > mutex_${N}_${cycle}_${mutex_delay}.xml
