#!/bin/sh
#
# This procedure assumes that the Tuxedo installation kit and silent response file have been
# downloaded to ~/Downloads.
#
# Created by Todd Little  1-Dec-2014
#
# Unzip the downloaded installation kit
unzip -qq tuxedo121300_64_Linux_01_x86.zip
# Run the installer in silent mode
#
# Installs all of Tuxedo including samples without LDAP support.  tlisten password is "oracle"
# Tuxedo home is ~/tuxhome
# TUXDIR is ~/tuxhome/tuxedo12.1.3.0.0
./Disk1/install/runInstaller -responseFile ~/Downloads/tuxedo12.1.3.rsp -silent -waitforcompletion
#
# Remove the installer, but not the kit or response file
rm -Rf Disk1
echo "Installation done"




