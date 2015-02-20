#
# Dockerfile for Tuxedo 12.1.3 ZIP Distro
# 
# Download the following files:
#   tuxedo121300_64_Linux_01_x86.zip	from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
#   p19927652_121300_Linux-x86-64.zip 	or whatever the latest Tuxedo rolling patch is from My Oracle Support
#   tuxedo12.1.3_silent_install.sh	from github
#   tuxedo12.1.3.rsp 			from github
#   simpapp_runme.sh			from github
#   start_tlisten.sh			from github
#
# and put them in the same dir as this Dockerfile
#
#

# Pull base image
FROM oraclelinux:7

MAINTAINER Todd Little <toddjlittle@gmail.com>

# Core install doesn't include unzip or gcc, add them
RUN yum -y install unzip gcc

# Create the installation directory tree and user tuxtest with a password of tuxtest
RUN groupadd -g 1000 tuxtest; useradd -b /home -m -g tuxtest -u 1000 -s /bin/bash tuxtest
RUN echo tuxtest:tuxtest | chpasswd; echo root:samplesvm | chpasswd

ADD tuxedo12.1.3_silent_install.sh tuxedo12.1.3.rsp p19927652_121300_Linux-x86-64.zip tuxedo121300_64_Linux_01_x86.zip /home/tuxtest/Downloads/
ADD simpapp_runme.sh start_tlisten.sh /home/tuxtest/

RUN chown tuxtest:tuxtest -R /home/tuxtest
WORKDIR /home/tuxtest/Downloads/
USER tuxtest

# Install Tuxedo, SALT, and TSAM Agent
RUN sh tuxedo12.1.3_silent_install.sh p19927652_121300_Linux-x86-64.zip tuxedo121300_64_Linux_01_x86.zip
ENV TUXDIR /home/tuxtest/tuxHome/tuxedo12.1.3.0.0

# Clean up installer files
RUN rm -Rf /home/tuxtest/Downloads/*
#
# Configure network ports
# tlisten	nlsaddr:5001  jmx:5002
# SALT 		http:5010
# WSL		5020
#EXPOSE 5001 5002 5010 5020
#USER root
#RUN yum -y install bind-utils

USER tuxtest
WORKDIR /home/tuxtest




