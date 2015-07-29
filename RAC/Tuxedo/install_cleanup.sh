#!/bin/sh
#
# Typically runs as user vagrant
#
# The version numbers to install may get passed in as a parameter
#
#   $1	tuxver
#   $2  icver
tuxver=12.1.3
icver=12.1
if [ -n "$1" ]
  then
    tuxver=$1
fi
echo "Tuxedo version = $tuxver"
if [ -n "$2" ]
  then
    icver=$2
fi
echo "Instant client version = $icver"
#
# Add address of EM to /etc/hosts
cp /etc/hosts hosts
echo "192.168.78.200	emcc.example.com" >>hosts
sudo mv hosts /etc/hosts

