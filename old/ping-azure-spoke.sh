#!/bin/bash

# check azure spokes 
privateIP='10.0.1.5'


count=1
wtime=2
min=800
max=188

# quicktest
for destIP in $privateIP; do
   ping $destIP -c3
done

   #for size in $(seq 800 1475); do
# ping failure from onprem to spoke 1373-1394 bytes
#
while true; do
   for size in $(seq 1300 1800); do
       for destIP in $privateIP; do
           ping $destIP -c $count -W $wtime -s $size > /dev/null
           if [ $? -eq 0 ]
           then
               printf "server %14s packet size $size count $count - PASSED\n" $destIP
           else
               printf "server %14s packet size $size count $count - FAILED !!!\n" $destIP
               exit
           fi
       done
   done
done
