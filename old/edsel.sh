#!/bin/bash

# check all spokes including shared services spoke
privateIP='10.224.0.93'
#privateIP='10.224.0.93 10.1.0.188 10.1.1.202 10.1.2.34'
count=2

# quicktest to build up the routing table
for destIP in $privateIP; do
   ping $destIP -c3
done

trigger=0
edsel_start="0:0:0"
edsel_end="0:0:0"

# packet size 1200 - 1475 bytes the hardest packet range to pass
# pingtest 80-100 bytes convergence test

# ping failure from onprem to spoke 1373-1394 bytes
#
while true; do
   for size in $(seq 100 101); do
       for destIP in $privateIP; do
           current_date_time=`date "+%Y-%m-%d-%H:%M:%S"`
           mystart=`date "+%H:%M:%S"`
           
           ping $destIP -c $count -W1 -s $size > /dev/null
           if [ $? -eq 0 ]
           then
               printf "server %14s packet size %6s count $count - PASSED %28s\n" $destIP $size $current_date_time
               if [ "$trigger" -eq 1 ]
               then
                   #string1="10:33:56"
                   #string2="10:36:10"
                   #end=$edsel_time
                   #echo $end
                   #edsel_end=`date "+%H:%M:%S"`
                   edsel_end=$mystart
                   echo $edsel_end
                   StartDate=$(date -u -d "$edsel_start" +"%s")
                   FinalDate=$(date -u -d "$edsel_end" +"%s")
                   date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S.%N"
                   date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S.%N"
                   exit
               fi

           else
               printf "server %14s packet size %6s count $count - FAILED %28s\n" $destIP $size $current_date_time
               echo $current_date_time >> converge.log
               #start=$edsel_time
               #edsel_start=`date "+%H:%M:%S"`
               
               if [ "$trigger" -eq 0 ]
               then
                   edsel_start=$mystart
                   echo $edsel_start
               fi
               trigger=1
               
           fi
       done
   done
done
