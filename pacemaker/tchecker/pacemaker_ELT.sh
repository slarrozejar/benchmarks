#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

TAVI=150
TLRI=1000
TVRP=150
TURI=400
TPVAB=50
thresh=350
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
echo "system:pacemaker_MS_${Aminwait}_${Amaxwait}_${Vminwait}_${Vmaxwait}
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
event:ABLOCK
event:VB
event:A_act
event:V_act
event:VP_AS
event:reset
"

# Global variables
echo "clock:1:clk
int:1:100:500:100:TPVARP
"

# Process LRI
echo "process:LRI
clock:1:t1
location:LRI:LRI{initial::invariant:t1<=1000-150}
location:LRI:Ased
edge:LRI:LRI:LRI:AP{provided:t1>=1000-150 : do:t1=0}
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
location:AVI:AVI{invariant:t2<=150}
location:AVI:WaitURI{invariant:clk<=400}
edge:AVI:Idle:AVI:AS{do:t2=0}
edge:AVI:Idle:AVI:AP{do:t2=0}
edge:AVI:AVI:Idle:VP{provided:t2>=150&&clk>=400}
edge:AVI:AVI:Idle:VS
edge:AVI:AVI:WaitURI:tau{provided:t2>=150&&clk<400}
edge:AVI:WaitURI:Idle:VP{provided:clk>=400}
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
location:PVARP:PVAB{invariant:t3<=50}
location:PVARP:PVARP{invariant:t3<=100}
location:PVARP:inter1{committed:}
location:PVARP:ABI{committed:}
edge:PVARP:Idle:PVAB:VS{do:t3=0}
edge:PVARP:Idle:PVAB:VP{do:t3=0}
edge:PVARP:PVAB:PVARP:tau{provided:t3>=50}
edge:PVARP:PVARP:Idle:tau{provided:t3>=100 : do:TPVARP=100}
edge:PVARP:PVARP:inter1:Aget
edge:PVARP:inter1:PVARP:AR
edge:PVARP:Idle:inter:Aget
edge:PVARP:inter:Idle:AS
edge:PVARP:Idle:inter:A_act
edge:PVARP:PVAB:ABI:A_act
edge:PVARP:PVAB:ABI:Aget
edge:PVARP:ABI:PVAB:ABLOCK
edge:PVARP:PVARP:inter1:A_act
"

# Process VRP
echo "process:VRP
clock:1:t4
location:VRP:Idle{initial:}
location:VRP:inter{committed:}
location:VRP:VRP{invariant:t4<=150}
edge:VRP:Idle:VRP:VP{do:t4=0}
edge:VRP:Idle:inter:Vget
edge:VRP:inter:VRP:VS{do:t4=0}
edge:VRP:VRP:Idle:tau{provided:t4>=150}
"

# Process RHM_A
echo "process:RHM_A
clock:1:t5
location:RHM_A:AReady{initial::invariant:t5<10000}
edge:RHM_A:AReady:AReady:AP{do:t5=0}
edge:RHM_A:AReady:AReady:Aget{provided:t5>0 : do:t5=0}
edge:RHM_A:AReady:AReady:A_act{do:t5=0}
"

# Process RHM_V
echo "process:RHM_V
clock:1:t6
location:RHM_V:VReady{initial::invariant:t6<10000}
edge:RHM_V:VReady:VReady:VP{do:t6=0}
edge:RHM_V:VReady:VReady:Vget{provided:t6>0 : do:t6=0}
edge:RHM_V:VReady:VReady:V_act{do:t6=0}
"

# Process Conduction
echo "process:Conduction
clock:1:t7
location:Conduction:Idle{initial:}
location:Conduction:Ante{invariant:t7<=10000}
location:Conduction:Retro{invariant:t7<=10000}
edge:Conduction:Idle:Idle:Aget
edge:Conduction:Idle:Idle:AP
edge:Conduction:Idle:Idle:Vget
edge:Conduction:Idle:Idle:VP
edge:Conduction:Ante:Idle:VP
edge:Conduction:Ante:Idle:Vget
edge:Conduction:Ante:Idle:V_act{provided:t7>=0}
edge:Conduction:Idle:Ante:Aget{do:t7=0}
edge:Conduction:Idle:Ante:AP{do:t7=0}
edge:Conduction:Retro:Idle:AP
edge:Conduction:Retro:Idle:Aget
edge:Conduction:Retro:Idle:A_act{provided:t7>=0}
edge:Conduction:Idle:Retro:Vget{do:t7=0}
edge:Conduction:Idle:Retro:VP{do:t7=0}
"

# Process Counter
echo "process:Counter
location:Counter:Init{initial:}
location:Counter:E1
location:Counter:E2
location:Counter:E3
location:Counter:E4
location:Counter:E5
location:Counter:E6
location:Counter:E7
location:Counter:E8
edge:Counter:Init:E1:VP_AS
edge:Counter:E1:E2:VP_AS
edge:Counter:E2:E3:VP_AS
edge:Counter:E3:E4:VP_AS
edge:Counter:E4:E5:VP_AS
edge:Counter:E5:E6:VP_AS
edge:Counter:E6:E7:VP_AS
edge:Counter:E7:E8:VP_AS
edge:Counter:E1:Init:reset
edge:Counter:E2:Init:reset
edge:Counter:E3:Init:reset
edge:Counter:E4:Init:reset
edge:Counter:E5:Init:reset
edge:Counter:E6:Init:reset
edge:Counter:E7:Init:reset
edge:Counter:E8:Init:tau{do:TPVARP=500}
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

# Process PELT_det
echo "process:PELT_det
location:PELT_det:VSed{initial:}
location:PELT_det:AS1
location:PELT_det:err
location:PELT_det:VP1
edge:PELT_det:VSed:AS1:AS
edge:PELT_det:VSed:err:AP
edge:PELT_det:VSed:err:AR
edge:PELT_det:VSed:err:ABLOCK
edge:PELT_det:VSed:err:VB
edge:PELT_det:VSed:VP1:VP
edge:PELT_det:VP1:err:VS
edge:PELT_det:AS1:err:AS
edge:PELT_det:AS1:err:AP
edge:PELT_det:AS1:err:AR
edge:PELT_det:AS1:err:ABLOCK
edge:PELT_det:AS1:err:VS
edge:PELT_det:AS1:err:VB
edge:PELT_det:AS1:VP1:VP
edge:PELT_det:VP1:err:VB
edge:PELT_det:VP1:err:AR
edge:PELT_det:VP1:err:ABLOCK
edge:PELT_det:VP1:err:AP
edge:PELT_det:VP1:err:VP
edge:PELT_det:VP1:AS1:AS
"

# Process Pv_v
echo "process:Pv_v
clock:1:t9
location:Pv_v:Init{initial:}
location:Pv_v:V1
location:Pv_v:V2{committed:}
location:Pv_v:err
edge:Pv_v:Init:V1:VP{do:t9=0}
edge:Pv_v:V1:V2:VP
edge:Pv_v:V2:V1:tau{provided:t9<=400 : do:t9=0}
edge:Pv_v:V2:err:tau{provided:t9>400}
"

# Process Detection
echo "process:Detection
clock:1:t10
location:Detection:Init{initial:}
location:Detection:VP1
location:Detection:AS1{committed:}
location:Detection:cancel{committed:}
edge:Detection:Init:VP1:VP{do:t10=0}
edge:Detection:VP1:AS1:AS
edge:Detection:VP1:cancel:VS
edge:Detection:VP1:cancel:AP
edge:Detection:VP1:cancel:AR
edge:Detection:cancel:Init:reset
edge:Detection:AS1:Init:VP_AS{provided:t10>=150&&t10<=200}
edge:Detection:AS1:Init:tau{provided:t10>200}
edge:Detection:AS1:Init:tau{provided:t10<150}
"

# Synchros
echo "sync:LRI@AP:AVI@AP?:RHM_A@AP?:PELT_det@AP?:Conduction@AP?:Detection@AP?
sync:AVI@VP:LRI@VP?:URI@VP?:PVARP@VP?:VRP@VP?:Pv_v@VP?:PURI_test@VP?:PELT_det@VP?:Conduction@VP?:Detection@VP?:RHM_V@VP?
sync:PVARP@AS:LRI@AS?:AVI@AS?:PELT_det@AS?:Detection@AS?
sync:PVARP@ABLOCK:PELT_det@ABLOCK?
sync:PVARP@AR:PELT_det@AR?:Detection@AR?
sync:VRP@VS:LRI@VS?:AVI@VS?:URI@VS?:PVARP@VS?:Pv_v@VS?:PURI_test@VS?:PELT_det@VS?:Detection@VS?
sync:RHM_A@Aget:PVARP@Aget?:Conduction@Aget?
sync:RHM_V@Vget:VRP@Vget?:Conduction@Vget?
sync:Conduction@V_act:RHM_V@V_act?
sync:Conduction@A_act:PVARP@A_act?:RHM_A@A_act?
sync:Detection@VP_AS:Counter@VP_AS?
sync:Detection@reset:Counter@reset?
"
