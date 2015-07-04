This directory contains the necessary vagrant files to create a VM with Tuxedo installed.

1) To use, download the following files from Oracle to ~/Downloads:
	tuxedo121300_64_Linux_01_x86.zip	Tuxedo 12.1.3 installer for Linux 64bit
	p19927652_121300_Linux-x86-64.zip	Latest Tuxedo patch kit (file name may be different)

2) Download and unzip the tuxedo_vagrant.zip file

3) Execute vagrant up


Contents of tuxedo_vagrant.zip file:
	fix_locations.sh	Shell script to fix up tokens such as locations, names, etc., in a file. It uses the contents of 
				tuxedo.vagrant to determine what tokens	should be substituted and their values.  Tokens are identified
				by enclosing their name in angle brackets like <INSTALLER_DIR>

	tuxedo.vagrant		The list of tokens and their values for this project

	tuxedo12.1.3_silent_install.sh.template
				Tuxedo silent install script template, meaning it needs to be fixed up with fix_locations

	tuxedo12.1.3.rsp.template
				A Tuxedo silent install response file that has been turned into a template

	install_tux.sh		Script to process the templates and then run the silent installer script

	Vagrantfile		The Vagrant file defining the machine and provisioning to be performed by Vagrant

	simpapp_runme.sh	Script to automatically build and run the simpapp sample application

	README.md		This file

	
