#!/bin/bash

# check all spokes including shared services spoke
privateIP='10.224.0.93'
#privateIP='10.224.0.93 10.1.0.188 10.1.1.202 10.1.2.34'

# check all spokes 
#privateIP='10.1.0.188 10.1.1.202 10.1.2.34'

count=1
wtime=2
min=800
max=188

# quicktest
for destIP in $privateIP; do
   ping $destIP -c3
done

scp -i mykey ubuntu@$destIP:/home/ubuntu/largefile.log .
