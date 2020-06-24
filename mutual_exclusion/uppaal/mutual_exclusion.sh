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
    R[1]=$1
    R[2]=$2
elif [ $# -eq 0 ]; then
    R[1]=0
    R[2]=0
else
    usage
    exit 1
fi

# Model

echo "<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE nta PUBLIC '-//Uppaal Team//DTD Flat System 1.1//EN' 'http://www.it.uu.se/research/group/darts/uppaal/flat-1_2.dtd'>
<nta>"

# Global variables

echo "	<declaration>
//Inspired from UPPAAL demo model introduced in Section 5 in:
//Martin Wehrle, Sebastian Kupferschmid:
//Mcta: Heuristics and Search for Timed Systems. FORMATS 2012: 252-266

clock S1_z;
clock S2_z;
clock Ctrl_z;
clock Ctrl_y0;
int[0,2] S1_IntStat := 0;
int[0,2] S2_IntStat := 0;
int[0,4] Ctrl_IntStat := 0;
int[0,1] Ctrl_grant1 := 0;
int[0,1] polled_S1_grant := 0;
int[0,1] Ctrl_grant2 := 0;
int[0,1] polled_S2_grant := 0;
int[0,1] S1_Safe := 0;
int[0,1] polled_Ctrl_Safe1 := 0;
int[0,1] S2_Safe := 0;
int[0,1] polled_Ctrl_Safe2 := 0;"
for i in `seq 1 2`; do
    if [ "${R[$i]}" -eq 1 ]; then
        echo "int[0,1] Root_req$i :=0;
int[0,1] polled_S${i}_request := 0;"
    fi
done
echo "</declaration>"

# Processes

ID=0

for i in `seq 1 2`; do
    echo "<template>
<name>S$i</name>"
    echo "<location id='id$ID'>
<name>start_S1</name>
<label kind='invariant'>S${i}_z &lt;= 0</label>
</location>"
    if [ $i -eq 1 ]; then
    		echo "<location id='id$(($ID+1))'>
<name>I_am_safe</name>
<label kind='invariant'>S${i}_z &lt;= 1000</label>
</location>
<location id='id$(($ID+2))'>
<name>I_am_unsafe</name>
<label kind='invariant'>S${i}_z &lt;= 1000</label>
</location>"
    else
      echo "<location id='id$(($ID+1))'>
<name>I_am_safe</name>
<label kind='invariant'>S${i}_z &lt;= 1001</label>
</location>
<location id='id$(($ID+2))'>
<name>I_am_unsafe</name>
<label kind='invariant'>S${i}_z &lt;= 1001</label>
</location>"
    fi
		echo "<init ref='id$ID'/>"
    if [ "${R[$i]}" -eq 1 ]; then
        echo "<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; polled_S${i}_request == 0 &amp;&amp; polled_S${i}_grant == 1 &amp;&amp; S${i}_Safe == 1</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>"
    fi
    echo "<transition>
<source ref='id$ID'/>
<target ref='id$(($ID+1))'/>
<label kind='assignment'>S${i}_Safe := 1, S${i}_IntStat := 0</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 2</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>S${i}_IntStat == 2</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>"
    if [ ${R[$i]} -eq 1 ]; then
        add=", polled_S${i}_request := Root_req$i"
    else
        add=""
    fi
    echo "<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 0 &amp;&amp; S${i}_z &gt; 0</label>
<label kind='assignment'>polled_S${i}_grant := Ctrl_grant$i, S${i}_IntStat := 1$add</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>S${i}_IntStat == 0 &amp;&amp; S${i}_z &gt; 0</label>
<label kind='assignment'>polled_S${i}_grant := Ctrl_grant$i, S${i}_IntStat := 1$add</label>
</transition>"
    if [ ${R[$i]} -eq 1 ]; then
        add="&amp;&amp; polled_S${i}_request == 0"
    else
        add=""
    fi
    echo "<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; polled_S${i}_grant == 0 &amp;&amp; S${i}_Safe == 1$add</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; S${i}_Safe == 0$add</label>
<label kind='assignment'>S${i}_Safe := 1, S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>"
    if [ ${R[$i]} -eq 1 ]; then
        add="&amp;&amp; polled_S${i}_request == 1"
    else
        add=""
    fi
    echo "<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; S${i}_Safe == 0$add</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; polled_S${i}_grant == 1 &amp;&amp; S${i}_Safe == 1$add</label>
<label kind='assignment'>S${i}_Safe := 0, S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>"
    if [ ${R[$i]} -eq 1 ]; then
        add="polled_S${i}_request == 1 &amp;&amp; polled_S${i}_grant == 0"
    else
        add="polled_S${i}_grant == 1"
    fi
    echo "<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>S${i}_IntStat == 1 &amp;&amp; $add &amp;&amp; S${i}_Safe == 1</label>
<label kind='assignment'>S${i}_IntStat := 0, S${i}_z := 0</label>
</transition>"
    echo "</template>"

ID=$(($ID+3))

done

for i in `seq 1 2`; do
    if [ ${R[$i]} -eq 1 ]; then
        echo "<template>
<name>drive_Root_req$i</name>
<location id='id$ID'>
<name>loop</name>
</location>
<init ref='id$ID'/>
<transition>
<source ref='id$ID'/>
<target ref='id$ID'/>
<label kind='guard'>Root_req$i == 1</label>
<label kind='assignment'>Root_req$i := 0</label>
</transition>
<transition>
<source ref='id$ID'/>
<target ref='id$ID'/>
<label kind='guard'>Root_req$i == 0</label>
<label kind='assignment'>Root_req$i := 1</label>
</transition>
</template>"

        ID=$(($ID+1))

    fi
done

echo "<template>
<name>Ctrl</name>
<location id='id$ID' x='40' y='80'>
<name>start_Ctrl</name>
<label kind='invariant'>Ctrl_z &lt;= 0</label>
</location>
<location id='id$(($ID+1))'>
<name>wait_for_s2</name>
<label kind='invariant'>Ctrl_z &lt;= 1000</label>
</location>
<location id='id$(($ID+2))'>
<name>g1</name>
<label kind='invariant'>Ctrl_z &lt;= 1000</label>
</location>
<location id='id$(($ID+3))'>
<name>wait_for_s1</name>
<label kind='invariant'>Ctrl_z &lt;= 1000</label>
</location>
<location id='id$(($ID+4))'>
<name>g2</name>
<label kind='invariant'>Ctrl_z &lt;= 1000</label>
</location>
<init ref='id$ID'/>
<transition>
<source ref='id$ID'/>
<target ref='id$(($ID+1))'/>
<label kind='assignment'>Ctrl_grant1 := 0, Ctrl_grant2 := 0, Ctrl_IntStat := 0</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 0 &amp;&amp; Ctrl_z &gt; 0</label>
<label kind='assignment'>polled_Ctrl_Safe1 := S1_Safe, polled_Ctrl_Safe2 := S2_Safe, Ctrl_IntStat := 1</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 2</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 0 &amp;&amp; Ctrl_grant1 == 0</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 1 &amp;&amp; Ctrl_grant1 == 0 &amp;&amp; Ctrl_y0 &lt; 2000</label>
<label kind='assignment'>Ctrl_IntStat := 2</label>
</transition>
<transition>
<source ref='id$(($ID+1))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 1 &amp;&amp; Ctrl_grant1 == 0 &amp;&amp; Ctrl_y0 &gt;= 2000</label>
<label kind='assignment'>Ctrl_grant1 := 1, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>Ctrl_IntStat == 0 &amp;&amp; Ctrl_z &gt; 0</label>
<label kind='assignment'>polled_Ctrl_Safe1 := S1_Safe, polled_Ctrl_Safe2 := S2_Safe, Ctrl_IntStat := 1</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>Ctrl_IntStat == 2</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 0 &amp;&amp; Ctrl_grant1 == 1</label>
<label kind='assignment'>Ctrl_grant1 := 0, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+2))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 1 &amp;&amp; Ctrl_grant1 == 1 &amp;&amp; Ctrl_y0 &lt; 2000</label>
<label kind='assignment'>Ctrl_IntStat := 2</label>
</transition>
<transition>
<source ref='id$(($ID+2))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 1 &amp;&amp; Ctrl_grant1 == 1 &amp;&amp; Ctrl_y0 &gt;= 2000</label>
<label kind='assignment'>Ctrl_grant1 := 0, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
<transition>
<source ref='id$(($ID+3))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 0 &amp;&amp; Ctrl_z &gt; 0</label>
<label kind='assignment'>polled_Ctrl_Safe1 := S1_Safe, polled_Ctrl_Safe2 := S2_Safe, Ctrl_IntStat := 1</label>
</transition>
<transition>
<source ref='id$(($ID+3))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 2</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+3))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 0 &amp;&amp; Ctrl_grant2 == 0</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+3))'/>
<target ref='id$(($ID+3))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 1 &amp;&amp; Ctrl_grant2 == 0 &amp;&amp; Ctrl_y0 &lt; 2000</label>
<label kind='assignment'>Ctrl_IntStat := 2</label>
</transition>
<transition>
<source ref='id$(($ID+3))'/>
<target ref='id$(($ID+4))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe1 == 1 &amp;&amp; Ctrl_grant2 == 0 &amp;&amp; Ctrl_y0 &gt;= 2000</label>
<label kind='assignment'>Ctrl_grant2 := 1, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
<transition>
<source ref='id$(($ID+4))'/>
<target ref='id$(($ID+4))'/>
<label kind='guard'>Ctrl_IntStat == 0 &amp;&amp; Ctrl_z &gt; 0</label>
<label kind='assignment'>polled_Ctrl_Safe1 := S1_Safe, polled_Ctrl_Safe2 := S2_Safe, Ctrl_IntStat := 1</label>
</transition>
<transition>
<source ref='id$(($ID+4))'/>
<target ref='id$(($ID+4))'/>
<label kind='guard'>Ctrl_IntStat == 2</label>
<label kind='assignment'>Ctrl_IntStat := 0, Ctrl_z := 0</label>
</transition>
<transition>
<source ref='id$(($ID+4))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 0 &amp;&amp; Ctrl_grant2 == 1</label>
<label kind='assignment'>Ctrl_grant2 := 0, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
<transition>
<source ref='id$(($ID+4))'/>
<target ref='id$(($ID+4))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 1 &amp;&amp; Ctrl_grant2 == 1 &amp;&amp; Ctrl_y0 &lt; 2000</label>
<label kind='assignment'>Ctrl_IntStat := 2</label>
</transition>
<transition>
<source ref='id$(($ID+4))'/>
<target ref='id$(($ID+1))'/>
<label kind='guard'>Ctrl_IntStat == 1 &amp;&amp; polled_Ctrl_Safe2 == 1 &amp;&amp; Ctrl_grant2 == 1 &amp;&amp; Ctrl_y0 &gt;= 2000</label>
<label kind='assignment'>Ctrl_grant2 := 0, Ctrl_IntStat := 0, Ctrl_z := 0, Ctrl_y0 := 0</label>
</transition>
</template>"


if [ ${R[1]} -eq 1 ]; then
    add1=", drive_Root_req1"
else
    add1=""
fi
if [ ${R[2]} -eq 1 ]; then
    add2=", drive_Root_req2"
else
    add2=""
fi

echo "<system>

system S1, S2, Ctrl$add1 $add2;</system>"

echo "<queries>
<query>
<formula>E&lt;&gt; (S1.I_am_unsafe and S2.I_am_unsafe)</formula>
<comment></comment>
</query>
</queries>"
echo "</nta>"
