#
# Dockerfile for Tuxedo 12.1.3 ZIP Distro
# 
# Download tuxedo121300_64_Linux_01_x86.zip from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
# and put it in the same dir as this Dockerfile
#
# https://github.com/weblogic-community/weblogic-docker
#

# Pull base image
FROM oraclelinux:6.5

MAINTAINER Todd Little <toddjlittle@gmail.com>

# Core install doesn't include unzip, add it
RUN yum -y install unzip
RUN yum -y install gcc

# Create the installation directory tree and user oracle
RUN mkdir /u01; chmod a+x /u01; chmod a+r /u01
RUN useradd -b /home -m -s /bin/bash oracle
RUN echo oracle:welcome1 | chpasswd
RUN echo root:oracle | chpasswd

ADD tuxedo121300_64_Linux_01_x86.zip /u01/
ADD install_tuxedo12.1.3.rsp /u01/
ADD simpapp_runme.sh /home/oracle/
ADD start_tlisten.sh /home/oracle/

RUN chown oracle:oracle -R /u01
RUN chown oracle:oracle -R /home/oracle
WORKDIR /u01
USER oracle

# Install Tuxedo, SALT, and TSAM Agent
RUN unzip /u01/tuxedo121300_64_Linux_01_x86.zip -d /u01/oracle/
WORKDIR /u01/oracle/Disk1/install
RUN ./runInstaller -silent -waitforcompletion -responseFile /u01/install_tuxedo12.1.3.rsp
RUN rm -Rf /u01/oracle/Disk1
RUN rm -f /u01/install_tuxedo12.1.3.rsp /u01/tuxedo121300_64_Linux_01_x86.zip
USER root
RUN sh /u01/app/oraInventory/orainstRoot.sh 
ENV TUXDIR /u01/oracle/tuxedoHome/tuxedo12.1.3.0.0

#
# Configure network ports
# tlisten	nlsaddr:5001  jmx:5002
# SALT 		http:5010
# WSL		5020
EXPOSE 5001 5002 5010 5020

USER oracle
WORKDIR /home/oracle
# Start tlisten so the machine can be managed
#CMD ["sh","start_tlisten.sh 5001 5002 && /usr/bin/bash"]





