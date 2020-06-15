#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

TAVI=150
TLRI=1000
TPVARP=100
TVRP=150
TURI=400
TPVAB=50
Aminwait=0
Amaxwait=10000
Vminwait=0
Vmaxwait=10000

usage() {
    echo "Usage: $0 Aminwait Amaxwait Vminwait Vmaxwait";
    echo "       Aminwait lower bound of the atrial heart interval (default: $Aminwait)"
    echo "       Amaxwait upper bound of the atrial heart interval (default: $Amaxwait)"
    echo "       Vminwait lower bound of the ventricular heart interval (default: $Vminwait)"
    echo "       Vmaxwait upper bound of the ventricular heart interval (default: $Vmaxwait)"
}

if [ $# -eq 4 ]; then
    Aminwait=$1
    Amaxwait=$2
    Vminwait=$3
    Vmaxwait=$4
elif [ $# -ne 0 ]; then
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

echo "# Zhihao Jiang, Miroslav Pajic, Salar Moarref, Rajeev Alur, Rahul Mangharam:
#Modeling and Verification of a Dual Chamber Implantable Pacemaker.
#TACAS 2012: 188-203.
"

echo "# The well treatment of bradycardia can be checked by verifying that processus
#Pvv in state two_a implies that its internal clock x is lower or equal to TLRI.
#The verification that the pacemaker does not pace the ventricles beyond a
#maximum rate can be checked by: PURI_test in state interval implies that its
#internal clock x is greater or equal to TURI.
"

echo "system:pacemaker_DDD_${Aminwait}_${Amaxwait}_${Vminwait}_${Vmaxwait}
"

# Events
echo "event:tau
event:AS
event:AP
event:AR
event:VP
event:VS
event:Aget
event:Vget
"

# Global variables
echo "clock:1:clk
"

# Process LRI
echo "process:LRI
clock:1:t1
location:LRI:LRI{initial::invariant:t1<=$TLRI-$TAVI}
location:LRI:Ased
edge:LRI:LRI:LRI:AP{provided:t1>=$TLRI-$TAVI : do:t1=0}
edge:LRI:LRI:LRI:VS{do:t1=0}
edge:LRI:LRI:LRI:VP{do:t1=0}
edge:LRI:LRI:Ased:AS
edge:LRI:Ased:LRI:VP{do:t1=0}
edge:LRI:Ased:LRI:VS{do:t1=0}
"

# Process AVI
echo "process:AVI
clock:1:t2
location:AVI:Idle{initial:}
location:AVI:AVI{invariant:t2<=$TAVI}
location:AVI:WaitURI{invariant:clk<=$TURI}
edge:AVI:Idle:AVI:AS{do:t2=0}
edge:AVI:Idle:AVI:AP{do:t2=0}
edge:AVI:AVI:Idle:VP{provided:t2>=$TAVI&&clk>=$TURI}
edge:AVI:AVI:Idle:VS
edge:AVI:AVI:WaitURI:tau{provided:t2>=$TAVI&&clk<$TURI}
edge:AVI:WaitURI:Idle:VP{provided:clk>=$TURI}
edge:AVI:WaitURI:Idle:VS
"

# Process URI
echo "process:URI
location:URI:URI{initial:}
edge:URI:URI:URI:VS{do:clk=0}
edge:URI:URI:URI:VP{do:clk=0}
"

# Process PVARP
echo "process:PVARP
clock:1:t3
location:PVARP:Idle{initial:}
location:PVARP:inter{committed:}
location:PVARP:PVAB{invariant:t3<=$TPVAB}
location:PVARP:PVARP{invariant:t3<=$TPVARP}
location:PVARP:inter1{committed:}
edge:PVARP:Idle:PVAB:VS{do:t3=0}
edge:PVARP:Idle:PVAB:VP{do:t3=0}
edge:PVARP:PVAB:PVARP:tau{provided:t3>=$TPVAB}
edge:PVARP:PVARP:Idle:tau{provided:t3>=$TPVARP}
edge:PVARP:PVARP:inter1:Aget
edge:PVARP:inter1:PVARP:AR
edge:PVARP:Idle:inter:Aget
edge:PVARP:inter:Idle:AS
"

# Process VRP
echo "process:VRP
clock:1:t4
location:VRP:Idle{initial:}
location:VRP:inter{committed:}
location:VRP:VRP{invariant:t4<=$TVRP}
edge:VRP:Idle:VRP:VP{do:t4=0}
edge:VRP:Idle:inter:Vget
edge:VRP:inter:VRP:VS{do:t4=0}
edge:VRP:VRP:Idle:tau{provided:t4>=$TVRP}
"

# Process RHM_A
echo "process:RHM_A
clock:1:t5
location:RHM_A:AReady{initial::invariant:t5<$Amaxwait}
edge:RHM_A:AReady:AReady:AP{do:t5=0}
edge:RHM_A:AReady:AReady:Aget{provided:t5>$Aminwait : do:t5=0}
"

# Process RHM_V
echo "process:RHM_V
clock:1:t6
location:RHM_V:VReady{initial::invariant:t6<$Vmaxwait}
edge:RHM_V:VReady:VReady:VP{do:t6=0}
edge:RHM_V:VReady:VReady:Vget{provided:t6>$Vminwait : do:t6=0}
"

# Process Pvv
echo "process:Pvv
clock:1:t7
location:Pvv:wait_1st{initial:}
location:Pvv:wait_2nd
location:Pvv:two_a{committed:}
edge:Pvv:wait_1st:wait_2nd:VS{do:t7=0}
edge:Pvv:wait_1st:wait_2nd:VP{do:t7=0}
edge:Pvv:wait_2nd:two_a:VS
edge:Pvv:wait_2nd:two_a:VP
edge:Pvv:two_a:wait_2nd:tau{do:t7=0}
"

# Process PURI_test
echo "process:PURI_test
clock:1:t8
location:PURI_test:wait_v{initial:}
location:PURI_test:wait_vp
location:PURI_test:interval{committed:}
edge:PURI_test:wait_v:wait_vp:VP{do:t8=0}
edge:PURI_test:wait_v:wait_vp:VS{do:t8=0}
edge:PURI_test:wait_vp:wait_vp:VS{do:t8=0}
edge:PURI_test:wait_vp:interval:VP
edge:PURI_test:interval:wait_vp:tau{do:t8=0}
"

# Synchros
echo "sync:LRI@AP:AVI@AP?:RHM_A@AP?
sync:AVI@VP:LRI@VP?:URI@VP?:PVARP@VP?:VRP@VP?:Pvv@VP?:PURI_test@VP?:RHM_V@VP?
sync:PVARP@AS:LRI@AS?:AVI@AS?
sync:VRP@VS:LRI@VS?:AVI@VS?:URI@VS?:PVARP@VS?:Pvv@VS?:PURI_test@VS?
sync:RHM_A@Aget:PVARP@Aget?
sync:RHM_A@Vget:VRP@Vget?
"
