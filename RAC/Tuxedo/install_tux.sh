#!/bin/sh
#
# Typically runs as user vagrant
#
# The version number to install may get passed in as a parameter
set -x
echo "Parameter = $1"
tuxver=12.1.3
if [ -n "$1" ]
  then
    tuxver=$1
fi
echo "Version = $tuxver"
#
# Set TUXDIR based upon the version being installed
if [ "$tuxver" = "12.1.3" ]
  then
    TUXDIR=/home/vagrant/tuxHome/tuxedo12.1.3.0.0
elif [ "$tuxver" = "12.1.1" ]
  then
    TUXDIR=/home/vagrant/tuxHome/tuxedo12.1.1.0.0
elif [ "$tuxver" = "11.1.1.3.0" ]
  then
    TUXDIR=/home/vagrant/tuxHome/tuxedo11.1.1.3.0
elif [ "$tuxver" = "11.1.1.2.0" ]
  then
    TUXDIR=/home/vagrant/tuxHome/tuxedo11.1.1.2.0
else
    echo "Unknown version to install"
fi
export TUXDIR=$TUXDIR
#
# Make a temporary directory to run the installers in
mkdir temp
#
# Now process the installation shell script template
cd /media/sf_tuxedo
# First add TUXDIR to the template values file
cp tuxedo.vagrant ~/tuxedo.vagrant
echo "TUXDIR	$TUXDIR" >> ~/tuxedo.vagrant
sh fix_locations.sh tuxedo.vagrant tuxedo${tuxver}_silent_install.sh.template >~/temp/tuxedo${tuxver}_silent_install.sh
#
# For Tuxedo 12.1.3 and later, process the .rsp template.  For Tuxedo 12.1.1 process the .properties template
if [ "$tuxver" = "12.1.3" ]
  then
    sh fix_locations.sh tuxedo.vagrant tuxedo${tuxver}.rsp.template >~/temp/tuxedo${tuxver}.rsp
elif [ "$tuxver" = "12.1.1" ]
  then
    sh fix_locations.sh tuxedo.vagrant tuxedo${tuxver}.installer.properties.template >~/temp/installer.properties
else
    echo "Unsupported Tuxedo version"
fi
# Run the installer in silent mode
cd ~/temp
sh tuxedo${tuxver}_silent_install.sh
# Clean up the temp directory
#rm -Rf ~/temp
# Add TUXDIR to profile
cat << EOF >> ~/.bashrc
export TUXDIR=${TUXDIR}
EOF
# Fix the location of the Oracle client libraries in the Tuxedo RM file
#patch /home/vagrant/tuxHome/tuxedo${tuxver}/udataobj/RM </media/sf_tuxedo/RM.patch
# Rename the Tuxedo /D sqlca.h out of the way
mv ${TUXDIR}/include/sqlca.h ${TUXDIR}/include/sqlca.h.save

