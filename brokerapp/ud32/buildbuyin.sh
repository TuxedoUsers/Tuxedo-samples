#!/bin/bash
#set -x
function usage {                                                                                                             
   echo "Usage : $0 [-c count] [-i interval] [-t total runtime]"                                                                              
}

function runclient {
accountid=100002;
CURDIR=$PWD;
cd /home/vmuser/application/brokerapp/ud32;
cat buy.ud32 >> buy.in
cat sell.ud32 >> buy.in
#echo "SRVCNM	BR_BUY_STOCK
#BROKERAGE_ACNT	$accountid" >> buy.in
#echo "SYMBOL	ORCL
#QUANTITY	100
#PRICE	10.2
#" >> buy.in
#echo "SRVCNM	BR_SELL_STOCK
#BROKERAGE_ACNT	$accountid
#SYMBOL	ORCL
#QUANTITY	100
#PRICE	10.2
#">> buy.in
cd $CURDIR;
}

if [[ $# -lt 1 ]]  
then
  usage; 
  exit 2;
fi

#Parse arguments
interval=10
totalcount=10
runtime=-1
while [[ $# -ge 1 ]] 
do
  if [[ $# -gt 4 && $1 != "-t" && $1 != "-i" ]]
  then
    usage;
    echo "Error : Unrecognized option '$1'"
    exit 6;
  fi
  
  if [[ $1 == "-c" ]]
  then
    if [[ $2 == "" ]]
    then
    usage;
    exit 3;
    fi
    totalcount=$2;
    shift 2;
    continue;
  fi

  if [[ $1 == "-i" ]]
  then
    if [[ $2 == "" ]]
    then
    usage;
    exit 3;
    fi
    interval=$2;
    shift 2;
    continue;
  fi
  
  if [[ $1 == "-t" ]]
  then
    if [[ $2 == "" ]]
    then
    usage;
    exit 3;
    fi
    runtime=$2;
    shift 2;
    continue;
  fi
done
count=0;
i=80000
while [[ count -lt $totalcount ]];
do
  if [[ $begintime == 0 ]]
  then
    begintime=$(date +%s);
  fi
  runclient $count;
  sleep $interval;
  begintime=0;
  if [ $runtime -gt 0 ]
  then
    now=$(date +%s);
    passedtime=$((now - begintime )); 
    if [ $passedtime -gt $runtime ]
    then
      break;
    fi
  fi
  let count=count+1;
done  
