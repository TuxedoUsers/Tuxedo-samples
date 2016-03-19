#
# Dockerfile template for Tuxedo 12.1.3
# 
# Download the following files to an empty directory:
#   tuxedo121300_64_Linux_01_x86.zip	from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html
#   p22090512_121300_Linux-x86-64.zip 	or whatever the latest Tuxedo rolling patch is from My Oracle Support
#
# Download and unzip into the same directory
#   tuxedo_docker.zip			from https://github.com/TuxedoUsers/Tuxedo-samples/tree/master/docker
#
#

# Pull base image
FROM oracle/tuxedo

MAINTAINER Todd Little <toddjlittle@gmail.com>
ADD simpappmp_runme.sh sleep.sh /home/tuxtest/

USER root
RUN chown tuxtest:tuxtest -R /home/tuxtest

USER tuxtest
RUN hostname
RUN mkdir /home/tuxtest/simpappmp
WORKDIR /home/tuxtest/simpappmp
RUN sh -x ../simpapp_runme.sh





