#!/bin/sh
#
# Typically runs as user vagrant
#
# Need to make some adjustments to the VM, and install some RPMs
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
sudo rpm -Uhv /media/sf_12cR1/oracle-instantclient12.1-precomp-12.1.0.2.0-1.x86_64.rpm
cat << EOF >tnsnames.ora
RACDBA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = collabn-cluster-scan.racattack)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdba)
    )
  )
EOF
chmod o+r tnsnames.ora
sudo mv tnsnames.ora /usr/lib/oracle/12.1/client64
cat << EOF >> ~/.bash_profile
export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH
export LIBPATH=${ORACLE_HOME}/lib:$LIBPATH
export PATH=${ORACLE_HOME}/bin:$PATH
export TNS_ADMIN=${ORACLE_HOME}
EOF

