#!/bin/bash

# check all spokes including shared services spoke
#privateIP='10.224.0.93 10.1.0.188 10.1.1.202 10.1.2.34'

# check all spokes including shared services spoke
privateIP='10.1.0.188 10.1.1.202 10.1.2.34'

count=1

# quicktest
for destIP in $privateIP; do
   ping $destIP -c3 -s 1373
done

   #for size in $(seq 800 1475); do
# ping failure from onprem to spoke 1373-1394 bytes
#
while true; do
   for size in $(seq 1372 1394); do
       for destIP in $privateIP; do
           ping $destIP -c $count -W1 -s $size > /dev/null
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
