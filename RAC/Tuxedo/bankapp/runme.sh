#!/bin/bash
#
# This script will build, boot, and run the complete Tuxedo bankapp sample application on one or two node
# environment using Oracle database.  As a base, start with the version of the sample that is on OTN that
# has already been updated to use Oracle database instead of /D.  It should be at:
#    http://download.oracle.com/otn/samplecode/bankapp.zip
#
#
# Usage:   runme.sh [mp]
#
# if mp or MP is the first parameter, run in a two node configuration, otherwise SHM
#
MODEL='shm'
if [ "$1" = 'mp' -o "$1" = 'MP' ]
  then
    MODEL=mp
fi

#
# Define a little function that just does a remote command if mp
do_remote () {
if [ "$MODEL" = 'mp' ]
  then
    ssh collaba2 "cd bankapp; . ./setenv.sh; $1"
fi
}

#
# Define another little function that does commands both locally and remotely
do_both () {
$1
do_remote "$1"
}


# Set up the environment variables
. ./setenv.sh
#
# Fix up the sources that are distributed by Oracle.
sh fixup_sources.sh

# Now fix up the locations in UBBCONFIG file
sh /media/sf_tuxedo/fix_locations.sh ~/tuxedo.vagrant ubb${MODEL} >ubb${MODEL}.tmp
mv ubb${MODEL}.tmp ubb${MODEL}

#
# Create all the executables and scripts
make -f bankapp.mk

#
# Create the Oracle TMS
buildtms -r Oracle_XA -o TMS_ORACLE

#
# Copy files to other node if needed
if [ "$MODEL" = 'mp' ]
  then
    scp -r ~/bankapp vagrant@collaba2:
fi

#
# Create the database
./crbank.sh scott/tiger@racdba racdba
#
# Load the configuration file
tmloadcf -y ubb${MODEL}
#
# Create the transaction log
./crtlog -m
if [ "$MODEL" = 'mp' ]
  then
    do_remote "./crtlog"
fi


#
# Create the queue space for /Q
./crqueue

#
# Start tlisten if needed
if [ "$MODEL" = 'mp' ]
  then
    do_both "sh starttlisten.sh"
fi

#
# Boot the application
tmboot -y
#
# Populate the database(s) with accounts
./populate

