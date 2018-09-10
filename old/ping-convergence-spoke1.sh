#!/bin/bash

# check all spokes including shared services spoke
privateIP='10.1.1.202'
#privateIP='10.224.0.93 10.1.0.188 10.1.1.202 10.1.2.34'
count=2
trigger=0

# quicktest to build up the routing table
for destIP in $privateIP; do
   ping $destIP -c3
done

# packet size 1200 - 1475 bytes the hardest packet range to pass
# pingtest 80-100 bytes convergence test

# ping failure from onprem to spoke 1373-1394 bytes
#
while true; do
   for size in $(seq 100 101); do
       for destIP in $privateIP; do
           current_date_time=`date "+%Y-%m-%d-%H:%M:%S.%N"`
           mystart=`date "+%H:%M:%S.%N"`
           
           ping $destIP -c $count -W1 -s $size > /dev/null
           if [ $? -eq 0 ]
           then
               printf "server %14s packet size %6s count $count - PASSED %28s\n" $destIP $size $current_date_time
               if [ "$trigger" -eq 1 ]
               then
                   FinalDate=$(date -u -d "$mystart" +"%s")
                   echo $mystart
                   echo "Traffic Convergence Time (hh:mm:ss):" >> converge.log
                   echo "Traffic Convergence Time (hh:mm:ss):" 
                   date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S.%N"
                   date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S.%N" >> converge.log

                   # again
                   ping $destIP -c $count -W1 -s $size > /dev/null
                   printf "server %14s packet size %6s count $count - PASSED %28s\n" $destIP $size $current_date_time
                   exit
               fi

           else
               echo $current_date_time >> converge.log
               if [ "$trigger" -eq 0 ]
               then
                   StartDate=$(date -u -d "$mystart" +"%s")
                   echo $mystart
               fi
               printf "server %14s packet size %6s count $count - FAILED %28s\n" $destIP $size $current_date_time
               trigger=1
               
           fi
       done
   done
done
