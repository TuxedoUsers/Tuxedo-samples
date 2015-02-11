#!/bin/sh
#
# Typically runs as user vagrant
#
# unzip is not necessarily included in the base image, and run the database preinstall just
# to make sure compilers, libraries, and some IPC settings are likely good.
sudo yum -y install unzip
#sudo yum -y install oracle-rdbms-server-11gR2-preinstall
#
# Make a temporary directory to run the installers in
#mkdir temp
cd temp
# Unzip the installer helper files
#unzip -o ~/Downloads/tuxedo_vagrant.zip
# Now process the installation templates
sh fix_locations.sh tuxedo.vagrant tuxedo12.1.3_silent_install.sh.template >tuxedo12.1.3_silent_install.sh
sh fix_locations.sh tuxedo.vagrant tuxedo12.1.3.rsp.template >tuxedo12.1.3.rsp
# Run the installer in silent mode
sh tuxedo12.1.3_silent_install.sh
# Clean up the temp directory
rm -Rf ~/temp


