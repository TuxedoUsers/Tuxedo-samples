#!/bin/bash
#
# This script will build, boot, and run the complete Tuxedo bankapp sample application on a single node
# environment using Oracle database.  As a base, start with the version of the sample that is on OTN that
# has already been updated to use Oracle database instead of /D.  It should be at:
#    http://download.oracle.com/otn/samplecode/bankapp.zip
#
# Set up the environment variables
. ./setenv.sh
#
# Fix up the sources that are distributed by Oracle.
sh fixup_sources.sh
#
# Create all the executables and scripts
make -f bankapp.mk
#
# Create the Oracle TMS
buildtms -r Oracle_XA -o TMS_ORACLE
#
# Create the database
./crbank.sh scott/tiger@racdba racdba
#
# Load the configuration file
tmloadcf -y ubbshm
#
# Create the transaction log
./crtlog -m
#
# Create the queue space for /Q
./crqueue
#
# Boot the application
tmboot -y
#
# Populate the database(s) with accounts
./populate

