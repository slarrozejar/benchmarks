#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

k=10
K=10

usage() {
    echo "Usage: $0 N";
    echo "       $0 N k K";
    echo "       N number of processes";
    echo "       k minimum delay for mutex (default: $k)"
    echo "       K maximum delay for mutex (default: $K)"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 3 ]; then
    N=$1
    k=$2
    K=$3
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

echo "# Inspired from UPPAAL demo model of Fischer's protocol introduced in:
# Martin Abadi and Leslie Lamport, An Old-Fashioned Recipe for Real Time, ACM
# Transactions on Programming Languages and Systems, 16(5) pp. 1543-1571, 1994.
"

echo "
# Mutual exclusion between process 1 and process 2 can be verified by checking
# unreachability of a configuration with labels cs1 and cs2
"

echo "system:fischer_${N}_${k}_$K
"

# Events

echo "event:tau
"

# Global variables

echo "int:1:0:$N:0:id
"

# Processes

for pid in `seq 1 $N`; do
    echo "# Process $pid
process:P$pid
clock:1:x$pid
location:P$pid:A{initial:}
location:P$pid:req{invariant:x$pid<=$K}
location:P$pid:wait{}
location:P$pid:cs{labels:cs$pid}
edge:P$pid:A:req:tau{provided:id==0 : do:x$pid=0}
edge:P$pid:req:wait:tau{provided:x$pid<=$K : do:x$pid=0;id=$pid}
edge:P$pid:wait:req:tau{provided:id==0 : do:x$pid=0}
edge:P$pid:wait:cs:tau{provided:x$pid>${k}&&id==$pid}
edge:P$pid:cs:A:tau{do:id=0}
"
done
