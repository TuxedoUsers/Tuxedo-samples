#!/bin/bash
#
# Script to start tlisten
cd ~/bankapp
. ./setenv.sh
tlisten -z 0 -Z 0 -l //${HOSTNAME}:7710 </dev/null >/dev/null 2>&1
