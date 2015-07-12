#!/bin/sh
#
# Typically runs as user vagrant
#
# unzip is not necessarily included in the base image, and run the database preinstall just
# to make sure compilers, libraries, and some IPC settings are likely good.
#sudo yum -y install unzip
#sudo yum -y install oracle-rdbms-server-11gR2-preinstall
#
# Make a temporary directory to run the installers in
mkdir temp
# Unzip the installer helper files
#unzip -o ~/Downloads/tuxedo_vagrant.zip
# Now process the installation templates
cd /media/sf_tuxedo
sh fix_locations.sh tuxedo.vagrant tuxedo12.1.3_silent_install.sh.template >~/temp/tuxedo12.1.3_silent_install.sh
sh fix_locations.sh tuxedo.vagrant tuxedo12.1.3.rsp.template >~/temp/tuxedo12.1.3.rsp
# Run the installer in silent mode
cd ~/temp
sh tuxedo12.1.3_silent_install.sh
# Clean up the temp directory
rm -Rf ~/temp
# Add TUXDIR to profile
cat << EOF >> ~/.bash_profile
export TUXDIR=/home/vagrant/tuxHome/tuxedo12.1.3.0.0
EOF
# Fix the location of the Oracle client libraries in the Tuxedo RM file
patch /home/vagrant/tuxHome/tuxedo12.1.3.0.0/udataobj/RM </media/sf_tuxedo/RM.patch
