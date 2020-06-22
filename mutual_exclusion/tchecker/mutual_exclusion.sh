#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

function usage() {
    echo "Usage: $0 ";
    echo "       $0 R1 R2";
    echo "       R1 request root 1, should be 0 or 1";
    echo "       R2 request root 2, should be 0 or 1";
    echo "       default: R1=0, R2=0"
}

if [ $# -eq 2 ]; then
    R1=$1
    R2=$2
elif [ $# -eq 0 ]; then
    R1=0
    R2=0
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

echo "system:mutual_exclusion_${R1}_${R2}
"

# Events

echo "event:tau
"

# Global variables

echo "clock:1:S1_z
clock:1:S2_z
clock:1:Ctrl_z
clock:1:Ctrl_y0
int:1:0:2:0:S1_IntStat
int:1:0:2:0:S2_IntStat
int:1:0:4:0:Ctrl_IntStat
int:1:0:1:0:Ctrl_grant1
int:1:0:1:0:polled_S1_grant
int:1:0:1:0:Ctrl_grant2
int:1:0:1:0:polled_S2_grant
int:1:0:1:0:S1_Safe
int:1:0:1:0:polled_Ctrl_Safe1
int:1:0:1:0:S2_Safe
int:1:0:1:0:polled_Ctrl_Safe2
"
for i in `seq 1 2`; do
    if [ $R$i -eq 1 ]; then
        echo "int:1:0:1:0:Root_req$i
    int:1:0:1:0:polled_S${i}_request
    "
    fi
done

# Processes
for i in `seq 1 2`; do
    echo "#Process S$i
process:S$i
location:S$i:start_S$i{initial: : invariant:S${i}_z<=0}
location:S$i:I_am_safe{invariant:S${i}_z<=1000}
location:S$i:I_am_unsafe{invariant:S${i}_z<=1000}
edge:S$i:start_S$i:I_am_safe:tau{do:S${i}_safe=1; S${i}_IntStat=0}
edge:S$i:I_am_unsafe:I_am_safe:tau{provided:S${i}_IntStat==2 : do:S${i}_IntStat=2; S${i}_z=0}
edge:S$i:I_am_unsafe:I_am_safe:tau{provided:S${i}_IntStat==2 : do:S${i}_IntStat=2; S${i}_z=0}"
    if [ $R$i -eq 1 ]; then
        add="polled_S${i}_request=Root_req$i"
    else
        add=""
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==0&&S${i}_z>0 : do:polled_S${i}_grant=Ctrl_grant$i; S${i}_IntStat=1; $add}
edge:S$i:I_am_unsafe:I_am_unsafe:tau{provided:S${i}_IntStat==0&&S${i}_z>0 : do:polled_S${i}_grant=Ctrl_grant$i; S${i}_IntStat=1; $add}"
    if [ $R$i -eq 1 ]; then
        add="polled_S${i}_request==0"
    else
        add="1"
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==1&&polled_S${i}_grant==0&&S${i}_Safe==1&&$add : do:S${i}_IntStat=0; S${i}_z=0}
edge:S$i:I_am_safe:I_am_unsafe:tau{provided:S${i}_IntStat==1&&polled_S${i}_grant==1&&S${i}_Safe==1&&$add : do:S${i}_IntStat=0; S${i}_z=0; S${i}_Safe=0}
edge:S$i:I_am_unsafe:I_am_safe:tau{provided:S${i}_IntStat==1&&S${i}_safe==0&&$add : do:S${i}_IntStat=0; S${i}_z=0; S${i}_Safe=1}"
    if [ $R$i -eq 1 ]; then
        add="polled_S${i}_request==1"
    else
        add="1"
    fi
    echo "edge:S$i:I_am_unsafe:I_am_unsafe:tau{provided:S${i}_IntStat==1&&S${i}_Safe==0&&$add : do:S${i}_IntStat=0; S${i}_z=0}"
    if [ $R$i -eq 1 ]; then
        add="polled_S${i}_request==1&&polled_S${i}_grant==0"
    else
        add="polled_S${i}_grant==1"
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==1&&S${i}_Safe==1&&$add : do:S${i}_IntStat=0; S${i}_z=0}"

    if [ $R$i -eq 1 ]; then
        echo "# Process drive_Root_req$i
process:drive_Root_req$i
location:drive_Root_req$i:loop{initial:}
edge:drive_Root_req$i:loop:loop:tau{provided:Root_req$i==1 : do:Root_req$i=0}
edge:drive_Root_req$i:loop:loop:tau{provided:Root_req$i==0 : do:Root_req$i=1}
"
    fi
done
