#!/bin/bash

# check all spokes including shared services spoke
privateIP='172.16.221.199'

count=2
wtime=3

# quicktest
for destIP in $privateIP; do
   ping $destIP -c3
done

# pingtest 500
   #for size in $(seq 800 1475); do
# ping failure from onprem to spoke 1373-1394 bytes
#
for number in {1..2} 
   do
   for size in $(seq 80 82) 
       do
       for destIP in $privateIP 
           do
           current_date_time=`date "+%Y-%m-%d-%H:%M:%S"`
           ping $destIP -c $count -W $wtime -s $size > /dev/null
           if [ $? -eq 0 ]
           then
               printf "server %14s packet size $size count $count - PASSED %20s\n" $destIP $current_date_time
           else
               printf "server %14s packet size $size count $count - FAILED !!!\n" $destIP
               exit 1
           fi
           done
       done
   done
exit 0
