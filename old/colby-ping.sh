#!/bin/bash

# check all spokes including shared services spoke
privateIP='10.224.0.93'
#privateIP='10.224.0.93 10.1.0.188 10.1.1.202 10.1.2.34'
count=1

# quicktest to build up the routing table
for destIP in $privateIP; do
   ping $destIP -c3
done

# packet size 1200 - 1475 bytes the hardest packet range to pass
# pingtest 80-100 bytes convergence test

# ping failure from onprem to spoke 1373-1394 bytes
#
while true; do
   for size in $(seq 80 100); do
       for destIP in $privateIP; do
           current_date_time=`date "+%Y-%m-%d-%H:%M:%S"`
           ping $destIP -c $count -W1 -s $size > /dev/null
           if [ $? -eq 0 ]
           then
               printf "server %14s packet size %6s count $count - PASSED %28s\n" $destIP $size $current_date_time
           else
               printf "server %14s packet size %6s count $count - FAILED %28s\n" $destIP $size $current_date_time
               #exit
           fi
       done
   done
done
