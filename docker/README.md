# Introduction
This folder contains the information and examples of how to use [Tuxedo](http://oracle.com/tuxedo) with [Docker](https://www.docker.com/).

## Contents
It is based on the WebLogic Server dockerization (is that even a word?) done by Bruno Borges.  Roughly the files are:

1. install_tuxedo12.1.3.rsp - This is a silent install answer file for Tuxedo 12.1.3.  It allows Tuxedo to be installed without any user interaction.
2. Dockerfile - The dockerfile used to take a base Oracle Linux 6.5 image and add Tuxedo to it
3. dockTuxedo.sh - Script to run the docker Tuxedo image
4. build.sh - Script to create the docker Tuxedo image
 


