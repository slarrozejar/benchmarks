#!/bin/sh

# This file is a part of the TickTac benchmarks project.
#
# See files AUTHORS and LICENSE for copyright details.

# For measuring WCRT
TS=1000000
MMI_MIPS=22
NAV_MIPS=113
RAD_MIPS=11
BUS_KBPS=72

# Change volume scenario
KEYPRESS1_PER_SEC=32
KP1_INSTR=100000
US1_INSTR=500000
AV_INSTR=1000000
AC1=0
VC1=1

# Adress look-up scenario
KEYPRESS2_PER_SEC=1
US2_INSTR=500000
KP2_INSTR=100000
DBL_INSTR=5000000
VC2=2

# TMC message handling scenario
MESSAGES_PER_MINUTE=20
HTMC_INSTR=1000000
DTMC_INSTR=5000000
US3_INSTR=500000
VC3=3

# Bus
BYTES4=$((8*4*$TS/($BUS_KBPS*1000)))
BYTES64=$((8*64*$TS/($BUS_KBPS*1000)))

# MMI
HK1=$((($KP1_INSTR/$MMI_MIPS)/(1000000/$TS)))
US1=$((($US1_INSTR/$MMI_MIPS)/(1000000/$TS)))
HK2=$((($KP2_INSTR/$MMI_MIPS)/(1000000/$TS)))
US2=$((($US2_INSTR/$MMI_MIPS)/(1000000/$TS)))
US3=$((($US3_INSTR/$MMI_MIPS)/(1000000/$TS)))

# NAV
DBL=$((($DBL_INSTR/$NAV_MIPS)/(1000000/$TS)))
DTMC=$((($DTMC_INSTR/$NAV_MIPS)/(1000000/$TS)))

# RAD
AV=$((($AV_INSTR/$RAD_MIPS)/(1000000/$TS)))
HTMC=$((($HTMC_INSTR/$RAD_MIPS)/(1000000/$TS)))

usage() {
    echo "Usage: $0 ";
}

if [ $# -ne 0 ]; then
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

echo "# Model extracted from: Martijn Hendriks, Marcel Verhoef:
#Timed automata based analysis of embedded system architectures. IPDPS 2006
"

echo "system:car_radio
"

# Events

echo "event:tau
event:signal0
event:signal1
event:signal2
event:signal3
event:hurry
"

# Global variables
echo "clock:1:rt
int 1:-32768:32767:-1:obs
int 1:-32768:32767:0:keypress1
int 1:-32768:32767:0:setvolume
int 1:-32768:32767:0:getvolume
int 1:-32768:32767:0:setvolume_out
int 1:-32768:32767:0:getvolume_out
int 1:-32768:32767:0:keypress2
int 1:-32768:32767:0:address_lookup
int 1:-32768:32767:0:nav_result
int 1:-32768:32767:0:address_lookup_out
int 1:-32768:32767:0:nav_result_out
int 1:-32768:32767:0:rec
int 1:-32768:32767:0:rec_nav
int 1:-32768:32767:0:htmc
int 1:-32768:32767:0:receive_out
int 1:-32768:32767:0:handle_tmc_out
"

# Processes
echo "# Process BusP
process:BusP
int:1:0:2147483648:D1
clock:1:y1
clock:1:x1
location:BusP:idle{initial:}
location:BusP:sending_nav_res{invariant:x1<=$BYTES64}
location:BusP:sending_db_lookup{invariant:x1<=$BYTES4}
location:BusP:sending_getvol{invariant:x1<=$BYTES4}
location:BusP:sending_setvol{invariant:x1<=$BYTES4}
location:BusP:sending_htmc{invariant:x1<=D1}
location:BusP:sending_receive{invariant:x1<=D1}
location:BusP:BP1{invariant:y1<=$BYTES4}
location:BusP:BP2{invariant:y1<=$BYTES64}
location:BusP:BP3{invariant:y1<=$BYTES4}
location:BusP:BP4{invariant:y1<=$BYTES4}
location:BusP:BP5{invariant:y1<=$BYTES4}
location:BusP:BP6{invariant:y1<=$BYTES64}
location:BusP:BP7{invariant:y1<=$BYTES4}
location:BusP:BP8{invariant:y1<=$BYTES4}
edge:BusP:sending_receive:BP1:hurry{provided:address_lookup_out>0 : do:address_lookup_out=address_lookup_out-1;y1=0}
edge:BusP:BP1:sending_receive:tau{provided: y1==$BYTES4 : do:address_lookup=address_lookup+1;D1=D1+$BYTES4}
edge:BusP:sending_receive:BP2:hurry{provided:nav_result_out>0 : do:nav_result_out=nav_result_out-1;y1=0}
edge:BusP:BP2:sending_receive:tau{provided:y1==BYTES64 : do:nav_result=nav_result+1;D1=D1+$BYTES64}
edge:BusP:sending_receive:BP3:hurry{provided:getvolume_out>0 : do:getvolume_out=getvolume_out-1;y1=0}
edge:BusP:BP3:sending_receive:tau{provided:y1==$BYTES4 : do:getvolume=getvolume+1;D1=D1+$BYTES4}
edge:BusP:sending_receive:BP4:hurry{provided:setvolume_out>0 : do:setvolume_out=setvolume_out-1;y1=0}
edge:BusP:BP4:sending_receive:tau{provided:y1==$BYTES4 : do:setvolume=setvolume+1;D1=D1+$BYTES4}
edge:BusP:sending_receive:idle:tau{provided:x1==D1 : do:rec_nav=rec_nav+1;D1=0}
edge:BusP:idle:sending_receive:hurry{provided:receive_out>0&&address_lookup_out==0&&nav_result_out==0&&getvolume_out==0&&setvolume_out==0 : do:receive_out=receive_out-1;x1=0;D1=$BYTES64}
edge:BusP:idle:sending_nav_res:hurry{provided:nav_result_out>0 : do:nav_result_out=nav_result_out-1;x1=0}
edge:BusP:sending_nav_res:idle:tau{provided:x1==$BYTES64 : do:nav_result=nav_result+1}
edge:BusP:sending_db_lookup:idle:tau{provided:x1==$BYTES4 : do:address_lookup=address_lookup+1}
edge:BusP:idle:sending_db_lookup:hurry{provided:address_lookup_out>0 : do:address_lookup_out=address_lookup_out-1}
edge:BusP:idle:sending_getvol:hurry{provided:getvolume_out>0 : do:getvolume_out=getvolume_out-1;x1=0}
edge:BusP:sending_getvol:idle:tau{provided:x1==$BYTES4 : getvolume=getvolume+1}
edge:BusP:idle:sending_setvol:hurry{provided:setvolume_out>0 : do:setvolume_out=setvolume_out-1;x1=0}
edge:BusP:sending_setvol:idle:tau{provided:x1==$BYTES4 : do:setvolume=setvolume+1}
edge:BusP:idle:sending_htmc:hurry{provided:handle_tmc_out>0&&address_lookup_out==0&&nav_result_out==0&&getvolume_out==0&&setvolume_out==0 : do:handle_tmc_out=handle_tmc_out-1;x1=0;D1=$BYTES64}
edge:BusP:sending_htmc:idle:tau{provided:x1==D1 : do:htmc=htmc+1;D1=0}
edge:BusP:BP8:sending_htmc:tau{provided:y1==$BYTES4 : do:setvolume=setvolume+1;D1=D1+$BYTES4}
edge:BusP:sending_htmc:BP8:hurry{provided:setvolume_out>0 : do:setvolume_out=setvolume_out-1;y1=0}
edge:BusP:BP7:sending_htmc:tau{provided:y1==$BYTES4 : do:getvolume=getvolume+1;D1=D1+$BYTES4}
edge:BusP:sending_htmc:BP7:hurry{provided:getvolume_out>0 : do:getvolume_out=getvolume_out-1;y1=0}
edge:BusP:BP6:sending_htmc:tau{provided:y1==$BYTES64 : do:nav_result=nav_result+1;D1=D1+$BYTES64}
edge:BusP:sending_htmc:BP6:hurry{provided:nav_result_out>0 : do:nav_result_out=nav_result_out-1;y1=0}
edge:BusP:BP5:sending_htmc:tau{provided:y1==$BYTES4 : do:address_lookup=address_lookup+1;D1=D1+$BYTES4}
edge:BusP:sending_htmc:BP5:hurry{provided:address_lookup_out>0 : address_lookup_out=address_lookup_out-1;y1=0}
"
