#!/bin/sh
#
# This procedure assumes that the following files have been downloaded to ~/Downloads:
#	database12.1.0.2.0_silent_install.sh	- This file
#	database12.1.0.2.0.rsp			- Silent install response file 
#	linuxamd64_12102_database_1of2.zip	- Part 1 of the database 12.1.0.2.0 installer
#	linuxamd64_12102_database_2of2.zip	- Part 2 of the database installer
#
# Usage:  sh database12.1.0.2.0_silent_install.sh
#
# Created by Todd Little  5-Dec-2014
#
# Perform pre-install step(s) -  These next steps require root access.  So either enable sudo for
# the account running this script, or execute these statements as root.
#
sudo yum-config-manager --enable ol7_addons*
sudo yum install oracle-rdbms-server-12cR1-preinstall
#
cd ~/Downloads
# Unzip the downloaded installation kit
unzip -qq linuxamd64_12102_database_1of2.zip
unzip -qq linuxamd64_12102_database_2of2.zip
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


