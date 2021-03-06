#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

usage() {
    echo "Usage: $0 N";
    echo "       N number of processes";
}

if [ $# -eq 1 ]; then
    N=$1
else
    usage
    exit 1
fi

# Model
echo "#clock:size:name
#int:size:min:max:init:name
#process:name
#event:name
#location:process:name{attributes}
#edge:process:source:target:event:{attributes}
#sync:events
#   where
#   attributes is a colon-separated list of key:value
#   events is a colon-separated list of process@event
"

echo "# Model from FIG 1 from:
# Georges Morbé, Florian Pigorsch, Christoph Scholl:
# Fully Symbolic Model Checking for Timed Automata. CAV 2011: 616-632
"

echo "
# In the article above, the property verified is the accessibility
# of a configuration where all processes are in state s1. Such a
# configuration is accessible.
"

echo "system:fig1-Morbe_et_al-CAV2011_${N}
"

# Events

echo "event:tau
"

# Global variables

echo "int:1:0:$N:0:i
"

# Processes
for pid in `seq 1 $N`; do
    echo "# Process $pid
process:P$pid
clock:1:x$pid
location:P$pid:s0{initial:}
location:P$pid:s1{invariant:x$pid<=5}
location:P$pid:s2{}
edge:P$pid:s0:s1:tau{provided:x$pid<=5}
edge:P$pid:s1:s2:tau{do:i=$pid}
edge:P$pid:s2:s0:tau{provided:i==$pid : do:x$pid=0;i=0}
"
done
