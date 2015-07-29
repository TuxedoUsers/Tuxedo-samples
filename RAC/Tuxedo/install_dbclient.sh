#!/bin/sh
#
# Typically runs as user vagrant
#
# The version number to install may get passed in as a parameter
echo "Parameter = $1"
icver=12.1
if [ -n "$1" ]
  then
    icver=$1
fi
echo "Version = $icver"
#
# Need to make some adjustments to the VM, and install some RPMs
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient${icver}-basic-*x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient${icver}-devel-*x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient${icver}-sqlplus-*x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient${icver}-precomp-*x86_64.rpm
cat << EOF >tnsnames.ora
RACDBA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = collabn-cluster-scan.racattack)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdba)
    )
  )
RAC1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = collabn1.racattack)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdba)
    )
  )
RAC2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = collabn2.racattack)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdba)
    )
  )

EOF
chmod o+r tnsnames.ora
sudo mv tnsnames.ora /usr/lib/oracle/${icver}/client64
cat << EOF >> ~/.bashrc
export LD_LIBRARY_PATH=/usr/lib/oracle/${icver}/client64/lib:$LD_LIBRARY_PATH
export LIBPATH=/usr/lib/oracle/${icver}/client64/lib:$LIBPATH
export PATH=/usr/lib/oracle/${icver}/client64/bin:$PATH
export TNS_ADMIN=/usr/lib/oracle/${icver}/client64
export ICVER=${icver}
EOF
#
# Replace reference to $ORACLE_HOME in Tuxedo RM file
sed -i -e "s=\${ORACLE_HOME}=/usr/lib/oracle/${icver}/client64=g" $TUXDIR/udataobj/RM


