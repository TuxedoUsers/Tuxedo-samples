#!/bin/sh
#
# This procedure assumes that the following files have been downloaded to ~/Downloads:
#	tuxedo12.1.3_silent_install.sh		- This file
#	tuxedo12.1.3.rsp			- Silent install response file 
#	tuxedo121300_64_Linux_01_x86.zip	- Tuxedo installation kit from Oracle
#	p19927652_121300_Linux-x86-64.zip	- Tuxedo lastest patch kit from Oracle - RP011
#
# Usage:  sh tuxedo12.1.3_silent_install.sh [patch-filename [tuxedo-installer-filename]]
#
# Created by Todd Little  1-Dec-2014
#
# Get the arguments
INSTALLER=tuxedo121300_64_Linux_01_x86.zip
PATCH=p19927652_121300_Linux-x86-64.zip
if [ ! -z "$1" ]
    then
	PATCH=$1
	if [ ! -z "$2" ]
	    then
		INSTALLER=$2
	fi
fi
echo "Using patch file $PATCH"
echo "Using Tuxedo installer $INSTALLER"
# Unzip the downloaded installation kit
unzip -qq $INSTALLER
# Run the installer in silent mode
#
# Installs all of Tuxedo including samples without LDAP support.  tlisten password is "oracle"
# Tuxedo home is ~/tuxhome
# TUXDIR is ~/tuxhome/tuxedo12.1.3.0.0
./Disk1/install/runInstaller -responseFile ~/Downloads/tuxedo12.1.3.rsp -silent -waitforcompletion
#
# Remove the installer, but not the kit or response file
rm -Rf Disk1
echo "Installation done, starting rolling patch"
#
# Install rolling patch
export ORACLE_HOME=~/tuxhome
unzip -qq $PATCH
# Get the patch zip file name from the patch kit name, get everything before the first _
zipname=`echo "$PATCH" | cut -d'_' -f1`
# Strip of the p at the beginning
zipname=${zipname:1:20}
$ORACLE_HOME/OPatch/opatch apply $zipname.zip
# Clean up patch files
rm -f $zipname.zip patchlev README.txt releasenotes.txt


