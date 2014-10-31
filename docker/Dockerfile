#
# Dockerfile for Tuxedo 12.1.3 ZIP Distro
# 
# Download tuxedo121300_64_Linux_01_x86.zip from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
# and put it in the same dir as this Dockerfile
#
# https://github.com/weblogic-community/weblogic-docker
#

# Pull base image
FROM oracle-linux:6.5

MAINTAINER Todd Little <todd.little@oracle.com>

# Core install doesn't include unzip, add it
RUN yum -y install unzip

# Create the installation directory tree and user oracle
RUN mkdir /u01; chmod a+x /u01; chmod a+r /u01
RUN useradd -b /home -m -s /bin/bash oracle
RUN echo oracle:welcome1 | chpasswd

ADD tuxedo121300_64_Linux_01_x86.zip /u01/tuxedo121300_64_Linux_01_x86.zip
ADD install_tuxedo12.1.3.rsp /u01/install_tuxedo12.1.3.rsp

RUN chown oracle:oracle -R /u01
WORKDIR /u01
USER oracle

# Install Tuxedo, SALT, and TSAM Agent
RUN unzip /u01/tuxedo121300_64_Linux_01_x86.zip -d /u01/oracle/
WORKDIR /u01/oracle/Disk1/install
RUN ./runInstaller -silent -waitforcompletion -responseFile /u01/install_tuxedo12.1.3.rsp
RUN rm -Rf /u01/oracle/Disk1
USER root
RUN sh /u01/app/oraInventory/orainstRoot.sh

# Expose tlisten ports (nlsaddr 8610, jmx 8620) and SALT port (8680)
EXPOSE 8610 8620 8680

USER oracle
WORKDIR /home/oracle
# Start tlisten so the machine can be managed
#RUN tlisten -j "rmi://tuxdemo.localdomain:3055" -l "//tuxdemo.localdomain:3050"
RUN source /u01/oracle/tuxedoHome/tuxedo12.1.3.0.0/tux.env; mkdir simpapp; cp $TUXDIR/samples/atmi/simpapp/* simpapp



