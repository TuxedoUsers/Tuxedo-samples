# Tuxedo and RAC Vagrant
This folder contains the necessary files to extend the racattack meets ansible-oracle project to include Tuxedo machines that include Tuxedo, Tuxedo patchset, and the Oracle Database instant client.

## Getting Started
To get started, clone the racattack meets ansible-oracle github project found at https://github.com/racattack/racattack-ansible-oracle

For a description of that project please see: https://oravirt.wordpress.com/2014/12/23/racattack-meet-ansible-oracle/

Once that project has been cloned, copy the RAC.zip file from this project to the root of the racattack-meet-ansible-oracle project and unzip the file there.

## Downloading from OTN and My Oracle Support
Because of distribution restrictions on Oracle licensed software, you will need to download and copy the following installers/kits into the 12cR1 directory of the project:

| File                                  | What it contains						|
| ------------------------------------- | -------------------------------				|
| linuxamd64_12102_database_1of2.zip	| Oracle Database 12.1.0.2 installer				|
| linuxamd64_12102_database_2of2.zip	|								|
| linuxamd64_12102_grid_1of2.zip	| Oracle Grid Infrastructure 12.1.0.2 installer			|
| linuxamd64_12102_grid_2of2.zip	|								|
| oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm	| Oracle Database Instant Client	|
| oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm	|					|
| oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm	|					|
| oracle-instantclient12.1-precomp-12.1.0.2.0-1.x86_64.rpm	|					|

And download and copy into the Tuxedo12cR2 directory:

| File                                  | What it contains						|
| ------------------------------------- | -------------------------------				|
| tuxedo121300_64_Linux_01_x86.zip	| Tuxedo 12.1.3 installer					|
| p19927652_121300_Linux-x86-64.zip	| Tuxedo rolling patch RP011					|
| bankapp.zip				| Updated Tuxedo bankapp sample using Oracle database		|

Note: The file p19927652_121300_Linux-x86-64.zip is the Tuxedo RP011 installer and needs to be downloaded from My Oracle Support, and not OTN.

# Configuring things
You will need edit the Vagrantfile file in the top level directory to determine the number of RAC nodes, the number of Tuxedo (application) nodes, and the resources such as memory to assign to each type of node.  Keep in mind that the minimum recommended memory for each RAC node is 3072 MB.  For the Tuxedo instances, 1000 MB is more than adequate.  You could probably get away with 512 MB for the Tuxedo instances.  So on an 8GB laptop you're probably limited to single instance RAC.  On a 16GB laptop you should be able to run with at least 2 RAC nodes and 3 or 4 Tuxedo nodes.

# Creating the VMs
Once you have everything in place and edited Vagrantfile, from the top level directory of the project (where Vagrantfile is located) issue these two commands:

	vagrant up
	setup=standard vagrant provision

and wait.  Depending upon your machine and the number of RAC instances selected, this can take anywhere from 30 minutes to well over an hour.  Once it completes, you will have N RAC nodes named collabn# where # is from 1 to N, and M Tuxedo nodes named collaba# where # is from 1 to M.  Single instance RAC works, and Flex Clusters are also supposed to work, although I haven't tried them.

# Post creation steps
Once the machines are up, you'll probably want to enable the scott/tiger accound and enable XA support in the database.  You can log into the RAC cluster by "vagrant ssh collabn1".  From there you'll need to switch to the oracle account by entering "sudo su - oracle".  After that execute the profile file by ". .profile_racdba" which will set up some environment variables and aliases.  Once those are done, start sqlplus as in "sqlplus / as sysdba" and enter the following SQL statements:

    vagrant ssh collabn1
    sudo su - oracle
    . .profile_racdba
    sqlplus / as sysdba
    alter user scott account unlock;
    alter profile default limit password_life_time unlimited;
    alter user scott identified by tiger;
    grant select on sys.dba_pending_transactions to scott;

# Setup verification
You should now be able to use "vagrant ssh collaba1" to access the first Tuxedo machine and the verify that sqlplus works by trying:

    sqlplus scott/tiger@racdba

If everthing has worked, you should get an SQL prompt and a message indicating you are connected to a RAC database.

# Running the bankapp sample
To run the bankapp sample, perform the following commands:

    vagrant ssh collaba1
    unzip /media/sf_tuxedo/bankapp.zip
    cp /media/sf_tuxedo/bankapp/* bankapp
    cd bankapp
    sh runme.sh [mp]

To run bankapp on a single node in SHM mode, leave off the optional mp paramter.  If you want to run in a two node configuration, pass the mp parameter to the runme.sh script.  The runme.sh will build everything, set up the environment, create the database tables, start the application, and then populate the the bank with accounts.
