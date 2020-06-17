#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

usage() {
    echo "Usage: ";
}

if [ $# -ne 0 ]; then
    N=$1
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

echo "system:stls
"

# Events

echo "event:tau
event:channel_SPS1_ControlUnit
event:channel_SPS1_AKT1
event:channel_SPS2_AKT2
"

# Global variables

echo "clock:1:ControlUnit_y0
clock:1:SPS1_z
clock:1:SPS2_z
int:1:0:6:0:ControlUnit_IntStat
int:1:0:4:0:AKT1_IntStat
int:1:0:4:0:AKT2_IntStat
int:1:0:1:0:ControlUnit_drive1
int:1:0:1:0:ControlUnit_drive2
int:1:0:1:0:polled_AKT2_permission
int:1:0:1:0:update_ControlUnit_drive1
int:1:0:1:0:update_ControlUnit_drive2
int:1:0:2:0:AKT2_signal
int:1:0:2:0:update_AKT2_signal
int:1:0:2:0:AKT1_signal
int:1:0:2:0:update_AKT1_signal
"

# Processes
echo "#process ControlUnit
process:ControlUnit
location:ControlUnit:Track1_Ready{initial:}
location:ControlUnit:Track1_Finished
location:ControlUnit:Track2_Finished
location:ControlUnit:Track1_Drive
location:ControlUnit:Track2_Drive
location:ControlUnit:Track2_Ready
edge:ControlUnit:Track1_Ready:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive1==0 : do:ControlUnit_IntStat=1}
edge:ControlUnit:Track1_Ready:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive1==0 : do:ControlUnit_IntStat=6}
edge:ControlUnit:Track1_Ready:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive1==0 : do:update_ControlUnit_drive1=1;ControlUnit_IntStat=4}
edge:ControlUnit:Track1_Ready:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Ready:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Ready:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Ready:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Ready:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Ready:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Finished:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_y0<20 : do:ControlUnit_IntStat=2}
edge:ControlUnit:Track1_Finished:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_y0>=20 : do:ControlUnit_IntStat=6}
edge:ControlUnit:Track1_Finished:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0 : do:ControlUnit_IntStat=2}
edge:ControlUnit:Track1_Finished:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Finished:Track1_Finished:channel_SPS1_ControlUnit{provided: ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0}
edge:ControlUnit:Track1_Finished:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Finished:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Finished:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Finished:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Finished:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_y0<19 : do:ControlUnit_IntStat=3}
edge:ControlUnit:Track2_Finished:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_y0>=19 : do:ControlUnit_IntStat=1}
edge:ControlUnit:Track2_Finished:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat == 0 : do:ControlUnit_IntStat=3}
edge:ControlUnit:Track2_Finished:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Finished:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Finished:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0}
edge:ControlUnit:Track2_Finished:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Finished:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Finished:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat == 6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive1==1 : do:update_ControlUnit_drive1=0;ControlUnit_IntStat=2}
edge:ControlUnit:Track1_Drive:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive1==1 : do:ControlUnit_IntStat=4}
edge:ControlUnit:Track1_Drive:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track1_Drive:Track2_Ready:channel_SPS1_ControlUnit{provided: ControlUnit_IntStat==6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive2==1 : do:update_ControlUnit_drive2=0;ControlUnit_IntStat=3}
edge:ControlUnit:Track2_Drive:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive2==1 : do:ControlUnit_IntStat=5}
edge:ControlUnit:Track2_Drive:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Drive:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive2==0 : do:ControlUnit_IntStat=6}
edge:ControlUnit:Track2_Ready:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive2==0 : do:update_ControlUnit_drive2=1;ControlUnit_IntStat=5}
edge:ControlUnit:Track2_Ready:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==0&&ControlUnit_drive2==0 : do:ControlUnit_IntStat=1}
edge:ControlUnit:Track2_Ready:Track1_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==1 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track1_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==2 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track2_Finished:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==3 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track1_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==4 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track2_Drive:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==5 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
edge:ControlUnit:Track2_Ready:Track2_Ready:channel_SPS1_ControlUnit{provided:ControlUnit_IntStat==6 : do:ControlUnit_IntStat=0;ControlUnit_y0=0}
"

for i in `seq 1 2`; do
    echo "# Process AKT$i
process:AKT$i
location:AKT$i:Idle{initial:}
location:AKT$i:Demanding
location:AKT$i:Driving
location:AKT$i:Error
edge:AKT$i:Idle:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&AKT${i}_signal==1 : do:AKT${i}_IntStat=1}
edge:AKT$i:Idle:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&AKT${i}_signal==1 : do:update_AKT${i}_signal=2;AKT${i}_IntStat=2}
edge:AKT$i:Idle:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&AKT${i}_signal==1 : do:AKT${i}_IntStat=4}
edge:AKT$i:Idle:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==1 : do:AKT${i}_IntStat=0}
edge:AKT$i:Idle:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==2 : do:AKT${i}_IntStat=0}
edge:AKT$i:Idle:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==3 : do:AKT${i}_IntStat=0}
edge:AKT$i:Idle:Error:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==4 : do:AKT${i}_IntStat=0}
edge:AKT$i:Demanding:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==1 : do:AKT${i}_IntStat=0}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==2 : do:AKT${i}_IntStat=0}
edge:AKT$i:Demanding:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==3 : do:AKT${i}_IntStat=0}
edge:AKT$i:Demanding:Error:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==4 : do:AKT${i}_IntStat=0}
edge:AKT$i:Driving:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==1 : do:AKT${i}_IntStat=0}
edge:AKT$i:Driving:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==2 : do:AKT${i}_IntStat=0}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==3 : do:AKT${i}_IntStat=0}
edge:AKT$i:Driving:Error:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==4 : do:AKT${i}_IntStat=0}
edge:AKT$i:Error:Error:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0 : do:AKT${i}_IntStat=4}
edge:AKT$i:Error:Idle:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==1 : do:AKT${i}_IntStat=0}
edge:AKT$i:Error:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==2 : do:AKT${i}_IntStat=0}
edge:AKT$i:Error:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==3 : do:AKT${i}_IntStat=0}
edge:AKT$i:Error:Error:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==4 : do:AKT${i}_IntStat=0}
"
    if [ $i -eq 1 ]; then
        cond="update_ControlUnit_drive1"
    else
        cond="polled_AKT2_permission"
    fi
    echo "edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==2 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=1}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==2 : do:AKT${i}_IntStat=2}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==2 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=4}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==2 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=1}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==2 : do:update_AKT${i}_signal=0;AKT${i}_IntStat=3}
edge:AKT$i:Demanding:Demanding:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==2 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=4}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==0 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=1}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==0 : do:update_AKT${i}_signal=2;AKT${i}_IntStat=2}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==0&&AKT${i}_signal==0 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=4}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==0 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=1}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==0 : do:AKT${i}_IntStat=3}
edge:AKT$i:Driving:Driving:channel_SPS${i}_AKT$i{provided:AKT${i}_IntStat==0&&$cond==1&&AKT${i}_signal==0 : do:update_AKT${i}_signal=1;AKT${i}_IntStat=4}
"
done

for i in `seq 1 2`; do
echo "# Process PLC_SPS$i
process:PLC_SPS$i
location:PLC_SPS$i:starting{initial: : invariant:SPS${i}_z<=0}
location:PLC_SPS$i:polling{invariant:SPS${i}_z<=10}
location:PLC_SPS$i:testing{invariant:SPS${i}_z<=10}
location:PLC_SPS$i:updating{invariant:SPS${i}_z<=10}
location:PLC_SPS$i:executing_AKT$i{invariant:SPS${i}_z<=10 : committed:}
location:PLC_SPS$i:resetting_AKT$i{invariant:SPS${i}_z<=0 : committed:}
edge:PLC_SPS$i:executing_AKT$i:updating:channel_SPS${i}_AKT$i
edge:PLC_SPS$i:resetting_AKT$i:polling:channel_SPS${i}_AKT$i
"
done

# Process PLC_SPS1
echo "location:PLC_SPS1:executing_ControlUnit
location:PLC_SPS1:resetting_ControlUnit
edge:PLC_SPS1:starting:polling:tau{do:update_AKT1_signal=1;update_ControlUnit_drive2=0;update_ControlUnit_drive1=0;AKT1_signal=1;ControlUnit_drive2=0;ControlUnit_drive1=0;ControlUnit_IntStat=0;AKT1_IntStat=0}
edge:PLC_SPS1:polling:testing:tau{provided:SPS1_z>0}
edge:PLC_SPS1:testing:executing_ControlUnit:tau
edge:PLC_SPS1:executing_ControlUnit:executing_AKT1:channel_SPS1_ControlUnit
edge:PLC_SPS1:updating:resetting_ControlUnit:tau{do:ControlUnit_drive1=update_ControlUnit_drive1;ControlUnit_drive2=update_ControlUnit_drive2;AKT1_signal=update_AKT1_signal;SPS1_z=0}
edge:PLC_SPS1:resetting_ControlUnit:resetting_AKT1:channel_SPS1_ControlUnit
"

# Process PLC_SPS2
echo "edge:PLC_SPS2:starting:polling:tau{do:update_AKT2_signal=1;AKT2_signal=1;AKT2_IntStat=0}
edge:PLC_SPS2:polling:testing:tau{provided:SPS2_z>0 : do:polled_AKT2_permission=ControlUnit_drive2}
edge:PLC_SPS2:testing:executing_AKT2:tau
edge:PLC_SPS2:updating:resetting_AKT2:tau{do:AKT2_signal=update_AKT2_signal;SPS2_z=0}
"

# Synchros
echo "sync:ControlUnit@channel_SPS1_ControlUnit:PLC_SPS1@channel_SPS1_ControlUnit
sync:AKT1@channel_SPS1_AKT1:PLC_SPS1@channel_SPS1_AKT1
sync:AKT2@channel_SPS2_AKT2:PLC_SPS2@channel_SPS2_AKT2
"
