#!/bin/bash

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# Check parameters

function usage() {
    echo "Usage: $0 ";
    echo "       $0 R1 R2";
    echo "       $0 N R1 R2"
    echo "       R1 request root 1, should be 0 or 1";
    echo "       R2 request root 2, should be 0 or 1";
    echo "       N set to 1 activates second mode of mutual exclusion"
    echo "       default: N=0, R1=0, R2=0"
}

if [ $# -eq 2 ]; then
    N=0
    R[1]=$1
    R[2]=$2
elif [ $# -eq 0 ]; then
    N=0
    R[1]=0
    R[2]=0
elif [ $# -eq 3 ]; then
    N=$1
    R[1]=$2
    R[2]=$3
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

echo "# Inspired from UPPAAL demo model introduced in Section 5 in:
#Martin Wehrle, Sebastian Kupferschmid:
#Mcta: Heuristics and Search for Timed Systems. FORMATS 2012: 252-266
"

echo "system:mutual_exclusion_${R[1]}_${R[2]}
"

# Events

echo "event:tau
"

# Global variables
if [ $N -eq 1 ]; then
    echo "clock:1:S1_x
clock:1:S2_x
clock:1:Ctrl_x"
fi
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
int:1:0:1:0:polled_Ctrl_Safe2"

for i in `seq 1 2`; do
    if [ "${R[$i]}" -eq 1 ]; then
        echo "int:1:0:1:0:Root_req$i
int:1:0:1:0:polled_S${i}_request"
    fi
done

# Processes
for i in `seq 1 2`; do
if [ $N -eq 1 ]; then
    cond="&&S${i}_x>0&&S${i}_z<1000"
    aff1=";S${i}_x=0"
    aff2=";S${i}_x=0;Ctrl_x=0"
else
    cond=""
    aff1=""
    aff2=""
fi
    echo "
#Process S$i
process:S$i
location:S$i:start_S$i{initial: : invariant:S${i}_z<=0}"
    if [ $i -eq 1 ]; then
        echo "location:S$i:I_am_safe{invariant:S${i}_z<=1000}
location:S$i:I_am_unsafe{invariant:S${i}_z<=1000}"
    else
      echo "location:S$i:I_am_safe{invariant:S${i}_z<=1001}
location:S$i:I_am_unsafe{invariant:S${i}_z<=1001}"
    fi
    if [ "${R[$i]}" -eq 1 ]; then
        echo "edge:S1:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==1&&polled_S${i}_request==0&&polled_S${i}_grant==1&&S${i}_Safe==1 : do:S${i}_IntStat=0;S${i}_z=0$aff1}"
    fi
    echo "edge:S$i:start_S$i:I_am_safe:tau{do:S${i}_Safe=1; S${i}_IntStat=0}
edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==2 : do:S${i}_IntStat=0; S${i}_z=0$aff1}
edge:S$i:I_am_unsafe:I_am_unsafe:tau{provided:S${i}_IntStat==2 : do:S${i}_IntStat=0; S${i}_z=0$aff1}"
    if [ ${R[$i]} -eq 1 ]; then
        add=";polled_S${i}_request=Root_req$i"
    else
        add=""
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==0&&S${i}_z>0$cond : do:polled_S${i}_grant=Ctrl_grant$i; S${i}_IntStat=1$add $aff1}
edge:S$i:I_am_unsafe:I_am_unsafe:tau{provided:S${i}_IntStat==0&&S${i}_z>0$cond : do:polled_S${i}_grant=Ctrl_grant$i; S${i}_IntStat=1$add $aff1}"
    if [ ${R[$i]} -eq 1 ]; then
        add="&&polled_S${i}_request==0"
    else
        add=""
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==1&&polled_S${i}_grant==0&&S${i}_Safe==1$add : do:S${i}_IntStat=0; S${i}_z=0$aff1}
edge:S$i:I_am_unsafe:I_am_safe:tau{provided:S${i}_IntStat==1&&S${i}_Safe==0$add : do:S${i}_IntStat=0; S${i}_z=0; S${i}_Safe=1$aff2}"
    if [ ${R[$i]} -eq 1 ]; then
        add="&&polled_S${i}_request==1"
    else
        add=""
    fi
    echo "edge:S$i:I_am_unsafe:I_am_unsafe:tau{provided:S${i}_IntStat==1&&S${i}_Safe==0$add : do:S${i}_IntStat=0; S${i}_z=0$aff1}
edge:S$i:I_am_safe:I_am_unsafe:tau{provided:S${i}_IntStat==1&&polled_S${i}_grant==1&&S${i}_Safe==1$add : do:S${i}_IntStat=0; S${i}_z=0; S${i}_Safe=0$aff2}"
    if [ ${R[$i]} -eq 1 ]; then
        add="polled_S${i}_request==1&&polled_S${i}_grant==0"
    else
        add="polled_S${i}_grant==1"
    fi
    echo "edge:S$i:I_am_safe:I_am_safe:tau{provided:S${i}_IntStat==1&&S${i}_Safe==1&&$add : do:S${i}_IntStat=0; S${i}_z=0$aff1}"

    if [ ${R[$i]} -eq 1 ]; then
        echo "
# Process drive_Root_req$i
process:drive_Root_req$i
location:drive_Root_req$i:loop{initial:}
edge:drive_Root_req$i:loop:loop:tau{provided:Root_req$i==1 : do:Root_req$i=0}
edge:drive_Root_req$i:loop:loop:tau{provided:Root_req$i==0 : do:Root_req$i=1}"
    fi
done

# Process Ctrl
echo "
# Process Ctrl
process:Ctrl
location:Ctrl:start_Ctrl{initial: : invariant:Ctrl_z<=0}
location:Ctrl:wait_for_s2{invariant:Ctrl_z<=1000}
location:Ctrl:g1{invariant:Ctrl_z<=1000}
location:Ctrl:wait_for_s1{invariant:Ctrl_z<=1000}
location:Ctrl:g2{invariant:Ctrl_z<=1000}
edge:Ctrl:start_Ctrl:wait_for_s2:tau{do:Ctrl_grant1=0;Ctrl_grant2=0;Ctrl_IntStat=0}
edge:Ctrl:wait_for_s2:wait_for_s2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==1&&Ctrl_grant1==0&&Ctrl_y0<2000 : do:Ctrl_IntStat=2}
edge:Ctrl:g1:g1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==1&&Ctrl_grant1==1&&Ctrl_y0<2000 : do:Ctrl_IntStat=2}
edge:Ctrl:wait_for_s1:wait_for_s1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==1&&Ctrl_grant2==0&&Ctrl_y0<2000 : do:Ctrl_IntStat=2}
edge:Ctrl:g2:g2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==1&&Ctrl_grant2==1&&Ctrl_y0<2000 : do:Ctrl_IntStat=2}"
if [ $N -eq 1 ]; then
    aff=";Ctrl_x=0"
else
    aff=""
fi
echo "edge:Ctrl:wait_for_s2:wait_for_s2:tau{provided:Ctrl_IntStat==2 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}
edge:Ctrl:wait_for_s2:wait_for_s2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==0&&Ctrl_grant1==0 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}
edge:Ctrl:g1:g1:tau{provided:Ctrl_IntStat==2 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}
edge:Ctrl:wait_for_s1:wait_for_s1:tau{provided:Ctrl_IntStat==2 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}
edge:Ctrl:wait_for_s1:wait_for_s1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==0&&Ctrl_grant2==0 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}
edge:Ctrl:g2:g2:tau{provided:Ctrl_IntStat==2 : do:Ctrl_IntStat=0;Ctrl_z=0$aff}"
if [ $N -eq 1 ]; then
    cond="&&Ctrl_x>0&&Ctrl_z<1000"
else
    cond=""
fi
echo "edge:Ctrl:wait_for_s2:wait_for_s2:tau{provided:Ctrl_IntStat==0&&Ctrl_z>0$cond : do:polled_Ctrl_Safe1=S1_Safe;polled_Ctrl_Safe2=S2_Safe;Ctrl_IntStat=1$aff}
edge:Ctrl:g1:g1:tau{provided:Ctrl_IntStat==0&&Ctrl_z>0$cond : do:polled_Ctrl_Safe1=S1_Safe;polled_Ctrl_Safe2=S2_Safe;Ctrl_IntStat=1$aff}
edge:Ctrl:wait_for_s1:wait_for_s1:tau{provided:Ctrl_IntStat==0&&Ctrl_z>0$cond : do:polled_Ctrl_Safe1=S1_Safe;polled_Ctrl_Safe2=S2_Safe;Ctrl_IntStat=1$aff}
edge:Ctrl:g2:g2:tau{provided:Ctrl_IntStat==0&&Ctrl_z>0$cond : do:polled_Ctrl_Safe1=S1_Safe;polled_Ctrl_Safe2=S2_Safe;Ctrl_IntStat=1$aff}"
if [ $N -eq 1 ]; then
    aff=";Ctrl_x=0;S1_x=0;S2_x=0"
else
    aff=""
fi
echo "edge:Ctrl:wait_for_s2:g1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==1&&Ctrl_grant1==0&&Ctrl_y0>=2000 : do:Ctrl_grant1=1;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}
edge:Ctrl:g1:wait_for_s1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==0&&Ctrl_grant1==1 : do:Ctrl_grant1=0;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}
edge:Ctrl:g1:wait_for_s1:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==1&&Ctrl_grant1==1&&Ctrl_y0>=2000 : do:Ctrl_grant1=0;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}
edge:Ctrl:wait_for_s1:g2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe1==1&&Ctrl_grant2==0&&Ctrl_y0>=2000 : do:Ctrl_grant2=1;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}
edge:Ctrl:g2:wait_for_s2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==0&&Ctrl_grant2==1 : do:Ctrl_grant2=0;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}
edge:Ctrl:g2:wait_for_s2:tau{provided:Ctrl_IntStat==1&&polled_Ctrl_Safe2==1&&Ctrl_grant2==1&&Ctrl_y0>=2000 : do:Ctrl_grant2=0;Ctrl_IntStat=0;Ctrl_z=0;Ctrl_y0=0$aff}"
