#
# Dockerfile for Tuxedo 12.1.3 ZIP Distro
# 
# Download tuxedo121300_64_Linux_01_x86.zip from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
# and put it in the same dir as this Dockerfile
#
#

# Pull base image
FROM oraclelinux:6.5

MAINTAINER Todd Little <toddjlittle@gmail.com>

# Core install doesn't include unzip, add it
RUN yum -y install unzip
RUN yum -y install gcc

# Create the installation directory tree and user tuxtest
#RUN mkdir /u01; chmod a+x /u01; chmod a+r /u01
RUN groupadd -g 1000 tuxtest
RUN useradd -b /home -m -g tuxtest -u 1000 -s /bin/bash tuxtest
RUN echo tuxtest:tuxtest | chpasswd
RUN echo root:samplesvm | chpasswd

ADD tuxedo121300_64_Linux_01_x86.zip /home/tuxtest/temp/
ADD install_tuxedo12.1.3.rsp /home/tuxtest/temp/
ADD simpapp_runme.sh /home/tuxtest/
ADD start_tlisten.sh /home/tuxtest/

#RUN chown tuxtest:tuxtest -R /u01
RUN chown tuxtest:tuxtest -R /home/tuxtest
WORKDIR /u01
USER tuxtest

# Install Tuxedo, SALT, and TSAM Agent
RUN unzip /home/tuxtest/temp/tuxedo121300_64_Linux_01_x86.zip -d /home/tuxtest/temp/
WORKDIR /home/tuxtest/temp/Disk1/install
RUN ./runInstaller -silent -waitforcompletion -responseFile /home/tuxtest/temp/install_tuxedo12.1.3.rsp
RUN rm -Rf /home/tuxtest/temp
#USER root
#RUN sh /u01/app/oraInventory/orainstRoot.sh 
ENV TUXDIR /home/tuxtest/tuxedoHome/tuxedo12.1.3.0.0

#
# Configure network ports
# tlisten	nlsaddr:5001  jmx:5002
# SALT 		http:5010
# WSL		5020
#EXPOSE 5001 5002 5010 5020
USER root
RUN yum -y install bind-utils

USER tuxtest
WORKDIR /home/tuxtest
# Start tlisten so the machine can be managed
#CMD ["sh","start_tlisten.sh 5001 5002 && /usr/bin/bash"]





