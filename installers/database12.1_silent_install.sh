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
# This script assume the following two steps have been done.  If not, please perform them before running
# this script.  These command run the Oracle Database preinstallation RPM to make sure the environment is
# set to run Oracle Database.
#
#sudo yum-config-manager --enable ol7_addons*
#sudo yum install oracle-rdbms-server-12cR1-preinstall
#
cd ~/Downloads
# Unzip the downloaded installation kit
#### unzip -qq linuxamd64_12102_database_1of2.zip
#### unzip -qq linuxamd64_12102_database_2of2.zip
# Run the installer in silent mode
#
# Installs all of Oracle Database setting up a pluggable database pdorcl in container database orcl.  Database
# password is welcome1.  ORACLE_HOME for the database is?
#
./database/runInstaller -responseFile ~/Downloads/database12.1.0.2.0.rsp -silent -waitforcompletion
#
# Do the root commands need to be executed?  Do them anyway.
sudo sh /home/oracle/app/oraInventory/orainstRoot.sh
sudo sh /home/oracle/app/oracle/product/12.1.0/dbhome_1/root.sh
# Run the configuration tool
/home/oracle/app/oracle/product/12.1.0/dbhome_1/cfgtoollogs/configToolAllCommands RESPONSE_FILE=~/Downloads/database12.1_config.rsp
# Remove the installer, but not the kit or response file
#### rm -Rf database
echo "Installation and Configuration done"


