#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

N=2
CORE=1
WCET=1
EXEC=1

function usage() {
    echo "Usage: $0 N";
    echo "       $0 N CORE";
    echo "       $0 N CORE WCET";
    echo "       N number of threads";
    echo "       CORE number of cores"
    echo "       WCET worse case execution time of the scheduler"
}

if [ $# -eq 1 ]; then
    N=$1
elif [ $# -eq 2 ]; then
    N=$1
    CORE=$2
elif [ $# -eq 3 ]; then
    N=$1
    CORE=$2
    WCET=$3
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

echo "# Safety critical protocol inspired from the model introduced in Section 3 in:
#Thomas Bøgholm, Henrik Kragh-Hansen, Petur Olsen, Bent Thomsen, Kim Guldstrand Larsen:
#Model-based schedulability analysis of safety critical hard real-time Java programs.
#JTRES 2008: 106-114
"

echo "
# Schedulabily of the processes can be verified by checking that no process is
#in its state Not_Schedulable.
"

echo "system:scheduler_${N}_${CORE}_$WCET
"

# Events
echo "event:tau
event:go"
for pid in `seq 1 $N`; do
    echo "event:run$pid
event:done$pid
event:ready$pid
event:invoke_code$pid
event:return_code$pid"
done

# Processes
for pid in `seq 1 $N`; do
    OFFSET=0
    DEADLINE=$(($N*6+$pid))
    PERIOD=$(($DEADLINE+2))
    echo "
# Process PeriodicThread$pid
process:PeriodicThread$pid
clock:1:released_time$pid
location:PeriodicThread$pid:initial{init: : urgent:}
location:PeriodicThread$pid:Release{urgent:}
location:PeriodicThread$pid:Scheduled{urgent:}
location:PeriodicThread$pid:Terminated{urgent:}
location:PeriodicThread$pid:CheckForOffest{invariant:released_time$pid<=$OFFSET}
location:PeriodicThread$pid:Schedulable
location:PeriodicThread$pid:Not_Schedulable
location:PeriodicThread$pid:Running
location:PeriodicThread$pid:Done{invariant:released_time$pid<=$PERIOD}
edge:PeriodicThread$pid:initial:CheckForOffest:go{do:released_time$pid=0}
edge:PeriodicThread$pid:CheckForOffset:Release:tau{provided:released_time$pid==$OFFSET}
edge:PeriodicThread$pid:Release:Schedulable:ready$pid{do:released_time$pid=0}
edge:PeriodicThread$pid:Schedulable:Scheduled:run$pid
edge:PeriodicThread$pid:Schedulable:Not_Schedulable:tau{provided:released_time$pid>$DEADLINE}
edge:PeriodicThread$pid:Scheduled:Running:invoke_code$pid
edge:PeriodicThread$pid:Running:Not_Schedulable:tau{provided:released_time$pid>$DEADLINE}
edge:PeriodicThread$pid:Not_Schedulable:Not_Schedulable:tau
edge:PeriodicThread$pid:Running:Terminated:return_code$pid{provided:released_time$pid<=$DEADLINE}
edge:PeriodicThread$pid:Terminated:Done:done$pid
edge:PeriodicThread$pid:Done:Release:tau{provided:released_time$pid==$PERIOD}"
done

for pid in `seq 1 $N`; do
    echo "
# Process Execution$pid
process:Execution$pid
clock:1:exec_execution_time$pid
location:Execution$pid:WaitingForRelease{initial:}
location:Execution$pid:Ready{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:If{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:IfThen{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:IfElse{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:IfEnd{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:Return{invariant:exec_execution_time$pid<=$EXEC}
location:Execution$pid:End{invariant:exec_execution_time$pid<=$EXEC}
edge:Execution$pid:WaitingForRelease:Ready:invoke_code$pid{do:exec_execution_time$pid=0}
edge:Execution$pid:Ready:If:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:If:IfElse:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:If:IfThen:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:IfThen:IfEnd:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:IfElse:IfEnd:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:IfEnd:Return:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:Return:End:tau{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}
edge:Execution$pid:Return:End:return_code$pid{provided:exec_execution_time$pid==$EXEC : do:exec_execution_time$pid=0}"
done

for id in `seq 1 $CORE`; do
    echo "
# Process Scheduler$id
process:Scheduler$id
clock:1:schedule_execution_time$id
int:1:1:$N:1:pid$id
int:$(($N+1)):0:1:0:schedulable$pid
location:Scheduler$id:initial{init: : urgent:}
location:Scheduler$id:Idle{urgent:}
location:Scheduler$id:Wait
location:Scheduler$id:Running{invariant:schedule_execution_time$id<=$WCET}
location:Scheduler$id:Schedule{urgent:}
location:Scheduler$id:Busy
edge:Scheduler$id:initial:Idle:go
edge:Scheduler$id:Running:Schedule:tau{provided:schedule_execution_time$id==$WCET : do:pid$id=1}
edge:Scheduler$id:Schedule:Schedule:tau{provided:schedulable[pid$id]==0 : do:pid=pid$id%$N+1}"
    for i in `seq 1 $N`; do
        echo "edge:Scheduler$id:Wait:Running:ready$i{do:schedulable[$i]=1;schedule_execution_time$id=0}
edge:Scheduler$id:Running:Running:ready$i{do:schedulable[$i]=1}
edge:Scheduler$id:Schedule:Schedule:ready$i{do:schedulable[$i]=1}
edge:Scheduler$id:Busy:Busy:ready$i{do:schedulable[$i]=1}
edge:Scheduler$id:Idle:Idle:ready$i{do:schedulable[$i]=1}
edge:Scheduler$id:Schedule:Busy:run$i{provided:pid$id==$i&&schedulable[$i]==1 : do:schedulable[$i]=0}
edge:Scheduler$id:Busy:Idle:done$i{provided:pid$id==$i}"
    done
    TMP=""
    for i in `seq 1 $(($N-1))`; do
        TMP="${TMP}schedulable[$i]==0&&"
    done
    TMP="${TMP}schedulable[$i]"
    echo "edge:Scheduler$id:Idle:Wait:tau{provided:$TMP}"
done
