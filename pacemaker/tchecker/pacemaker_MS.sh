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
thresh=350
Aminwait=100
Amaxwait=200
Vminwait=100
Vmaxwait=200

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

echo "system:pacemaker_MS_${Aminwait}_${Amaxwait}_${Vminwait}_${Vmaxwait}
"

# Events
echo "event:tau
event:AS
event:AP
event:AR
event:VPr
event:VPs
event:VS
event:Aget
event:Vget
event:VDI
event:DDD
event:Fast
event:Slow
event:du_end
event:du_beg
"

# Global variables
echo "clock:1:clk
"

# Process LRI_MS
echo "process:LRI_MS
clock:1:t1
location:LRI_MS:LRI{initial::invariant:t1<=$TLRI-$TAVI}
location:LRI_MS:VDI_LRI{invariant:t1<=$TLRI}
location:LRI_MS:aSensed
edge:LRI_MS:LRI:LRI:AP{provided:t1>=$TLRI-$TAVI : do:t1=0}
edge:LRI_MS:LRI:LRI:VS{do:t1=0}
edge:LRI_MS:LRI:LRI:VPr{do:t1=0}
edge:LRI_MS:LRI:VDI_LRI:VDI
edge:LRI_MS:VDI_LRI:LRI:DDD{do:t1=0}
edge:LRI_MS:VDI_LRI:VDI_LRI:VS{do:t1=0}
edge:LRI_MS:VDI_LRI:VDI_LRI:VPs{provided:t1>=$TLRI : do:t1=0}
edge:LRI_MS:aSensed:VDI_LRI:VDI
edge:LRI_MS:aSensed:VDI_LRI:VPr{do:t1=0}
edge:LRI_MS:aSensed:VDI_LRI:VS{do:t1=0}
edge:LRI_MS:VDI_LRI:aSensed:AS
"

# Process AVI_MS
echo "process:AVI_MS
clock:1:t2
location:AVI_MS:Idle{initial:}
location:AVI_MS:AVI{invariant:t2<=$TAVI}
location:AVI_MS:WaitURI{invariant:clk<=$TURI}
location:AVI_MS:VDI_idle
location:AVI_MS:VDI_AVI{invariant:t2<=$TAVI}
edge:AVI_MS:Idle:AVI:AS{do:t2=0}
edge:AVI_MS:Idle:AVI:AP{do:t2=0}
edge:AVI_MS:AVI:Idle:VPs{provided:t2>=$TAVI&&clk>=$TURI}
edge:AVI_MS:AVI:Idle:VS
edge:AVI_MS:AVI:WaitURI:tau{provided:t2>=$TAVI&&clk<$TURI}
edge:AVI_MS:WaitURI:Idle:VPs{provided:clk>=$TURI}
edge:AVI_MS:WaitURI:Idle:VS
edge:AVI_MS:WaitURI:VDI_idle:VDI{do:t2=0}
edge:AVI_MS:VDI_idle:Idle:DDD
edge:AVI_MS:Idle:VDI_idle:VDI
edge:AVI_MS:VDI_idle:VDI_AVI:AS{do:t2=0}
edge:AVI_MS:VDI_idle:VDI_AVI:AP{do:t2=0}
edge:AVI_MS:VDI_AVI:VDI_idle:tau{provided:t2>=$TAVI}
edge:AVI_MS:VDI_AVI:VDI_idle:VS
edge:AVI_MS:VDI_AVI:AVI:DDD
edge:AVI_MS:AVI:VDI_AVI:VDI
"


# Process URI
echo "process:URI
location:URI:URI{initial:}
edge:URI:URI:URI:VS{do:clk=0}
edge:URI:URI:URI:VPr{do:clk=0}
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
edge:PVARP:Idle:PVAB:VPr{do:t3=0}
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
edge:VRP:Idle:VRP:VPr{do:t4=0}
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
edge:RHM_V:VReady:VReady:VPr{do:t6=0}
edge:RHM_V:VReady:VReady:Vget{provided:t6>$Vminwait : do:t6=0}
"

# Process Interval
echo "process:Interval
clock:1:t7
location:Interval:Wait1st{initial:}
location:Interval:wait2nd
location:Interval:Resett{committed:}
location:Interval:APed{committed:}
edge:Interval:Wait1st:wait2nd:AP{do:t7=0}
edge:Interval:Wait1st:wait2nd:AR{do:t7=0}
edge:Interval:Wait1st:wait2nd:AS{do:t7=0}
edge:Interval:wait2nd:Resett:AS
edge:Interval:wait2nd:Resett:AR
edge:Interval:Resett:wait2nd:Fast{provided:t7<=$thresh : do:t7=0}
edge:Interval:Resett:wait2nd:Slow{provided:t7>$thresh : do:t7=0}
edge:Interval:wait2nd:APed:AP
edge:Interval:wait2nd:APed:Slow{do:t7=0}
"

# Process Counter
echo "process:Counter
location:Counter:Init{initial:}
location:Counter:switch1{committed:}
location:Counter:fast1
location:Counter:fast2
location:Counter:fast3
location:Counter:fast4
location:Counter:fast5
location:Counter:fast6
location:Counter:fast7
location:Counter:fast8
location:Counter:switch2{committed:}
location:Counter:c1{committed:}
location:Counter:c2{committed:}
location:Counter:c3{committed:}
location:Counter:c4{committed:}
location:Counter:c5{committed:}
location:Counter:c6{committed:}
location:Counter:c7{committed:}
location:Counter:c8{committed:}
edge:Counter:Init:fast1:Fast
edge:Counter:fast1:fast2:Fast
edge:Counter:fast2:fast3:Fast
edge:Counter:fast3:fast4:Fast
edge:Counter:fast4:fast5:Fast
edge:Counter:fast5:fast6:Fast
edge:Counter:fast6:fast7:Fast
edge:Counter:fast7:fast8:Fast
edge:Counter:switch1:Init:DDD
edge:Counter:fast1:switch1:Slow
edge:Counter:fast2:fast1:Slow
edge:Counter:fast3:fast2:Slow
edge:Counter:fast4:fast3:Slow
edge:Counter:fast5:fast4:Slow
edge:Counter:fast6:fast5:Slow
edge:Counter:fast7:fast6:Slow
edge:Counter:fast8:fast7:Slow
edge:Counter:switch2:fast8:VDI
edge:Counter:c8:fast8:du_beg
edge:Counter:fast8:switch2:du_end
edge:Counter:c1:fast1:VDI
edge:Counter:c2:fast2:VDI
edge:Counter:c3:fast3:VDI
edge:Counter:c4:fast4:VDI
edge:Counter:c5:fast5:VDI
edge:Counter:c6:fast6:VDI
edge:Counter:c7:fast7:VDI
edge:Counter:fast1:c1:du_end
edge:Counter:fast2:c2:du_end
edge:Counter:fast3:c3:du_end
edge:Counter:fast4:c4:du_end
edge:Counter:fast5:c5:du_end
edge:Counter:fast6:c6:du_end
edge:Counter:fast7:c7:du_end
"

# Process Duration
echo "process:Duration
location:Duration:Init{initial:}
location:Duration:V0
location:Duration:V1
location:Duration:V2
location:Duration:V3
location:Duration:V4
location:Duration:V5
location:Duration:V6
location:Duration:V7
location:Duration:V8{committed:}
edge:Duration:Init:V0:du_beg
edge:Duration:V0:V1:VS
edge:Duration:V1:V2:VS
edge:Duration:V2:V3:VS
edge:Duration:V3:V4:VS
edge:Duration:V4:V5:VS
edge:Duration:V5:V6:VS
edge:Duration:V6:V7:VS
edge:Duration:V7:V8:VS
edge:Duration:V0:V1:VPr
edge:Duration:V1:V2:VPr
edge:Duration:V2:V3:VPr
edge:Duration:V3:V4:VPr
edge:Duration:V4:V5:VPr
edge:Duration:V5:V6:VPr
edge:Duration:V6:V7:VPr
edge:Duration:V7:V8:VPr
edge:Duration:V8:Init:du_end
# Process Pv_v
"

echo "process:Pv_v
clock:1:t8
location:Pv_v:wait_1st{initial:}
location:Pv_v:wait_2nd
location:Pv_v:two_v{committed:}
location:Pv_v:err
edge:Pv_v:wait_1st:wait_2nd:VS{do:t8=0}
edge:Pv_v:wait_1st:wait_2nd:VPr{do:t8=0}
edge:Pv_v:wait_2nd:two_v:VS
edge:Pv_v:wait_2nd:two_v:VPr
edge:Pv_v:two_v:wait_2nd:tau{provided:t8<=$TURI : do:t8=0}
edge:Pv_v:two_v:err:tau{provided:t8>$TURI}
"

# Process PURI_test
echo "process:PURI_test
clock:1:t9
location:PURI_test:wait_v{initial:}
location:PURI_test:wait_vp  
location:PURI_test:interval{committed:}
edge:PURI_test:wait_v:wait_vp:VPr{do:t9=0}
edge:PURI_test:wait_v:wait_vp:VS{do:t9=0}
edge:PURI_test:wait_vp:wait_vp:VS{do:t9=0}
edge:PURI_test:wait_vp:interval:VPr
edge:PURI_test:interval:wait_vp:tau{do:t9=0}
"

# Process PMS
echo "process:PMS
location:PMS:Idle{initial:}
location:PMS:err
edge:PMS:Idle:err:VDI
"

# Synchros
echo "sync:LRI_MS@AP:AVI_MS@AP?:RHM_A@AP?:Interval@AP?
sync:LRI_MS@VPs:URI@VPr?:PVARP@VPr?:VRP@VPr?:Pv_v@VPr?:PURI_test@VPr?:Duration@VPr?:RHM_V@VPr?
sync:AVI_MS@VPs:LRI_MS@VPr?:URI@VPr?:PVARP@VPr?:VRP@VPr?:Pv_v@VPr?:PURI_test@VPr?:Duration@VPr?:RHM_V@VPr?
sync:PVARP@AS:LRI_MS@AS?:AVI_MS@AS?:Interval@AS?
sync:PVARP@AR:Interval@AR?
sync:VRP@VS:LRI_MS@VS?:AVI_MS@VS?:URI@VS?:PVARP@VS?:Pv_v@VS?:PURI_test@VS?:Duration@VS?
sync:RHM_A@Aget:PVARP@Aget?
sync:RHM_V@Vget:VRP@Vget?
sync:Interval@Fast:Counter@Fast?
sync:Interval@Slow:Counter@Slow?
sync:Counter@VDI:LRI_MS@VDI?:AVI_MS@VDI?:PMS@VDI?
sync:Counter@DDD:LRI_MS@DDD?:AVI_MS@DDD?
sync:Counter@du_beg:Duration@du_beg?
sync:Duration@du_end:Counter@du_end?
"
