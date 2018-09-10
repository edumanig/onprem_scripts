#!/bin/bash

#server    10.224.0.93 packet size    100 count 2 - FAILED          2018-04-07-01:31:32
#server    10.224.0.93 packet size    101 count 2 - FAILED          2018-04-07-01:31:34
#server    10.224.0.93 packet size    100 count 2 - FAILED          2018-04-07-01:31:36
#server    10.224.0.93 packet size    101 count 2 - FAILED          2018-04-07-01:31:38
#server    10.224.0.93 packet size    100 count 2 - FAILED          2018-04-07-01:31:40

           edsel_time=`date "+%H:%M:%S"`
           echo $edsel_time
                   string1="01:31:32"
                   string2="01:31:40"
                   StartDate=$(date -u -d "$string1" +"%s")
                   FinalDate=$(date -u -d "$string2" +"%s")
                   date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S.%N"
