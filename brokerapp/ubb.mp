#
# UBBCONFIG file for the bankapp/brokerapp demo on the BROKER domain
#
# There are 3 bankapp domains and one brokerapp domain.  They are as follows:
#
# Dom/AP	      LDom/LAP  WSL	   JSL	   HTTP          Oracle
#  Name		      Port	    Port   Port	   Port	  Bank   User        
#------------------------------------------------------------------------------------------------------------------
#   SANFRANCISCO  8300	    8310   8320	   8330	  B1     tuxdemo1
#   CHICAGO		  8400	    8410   8420	   8430   B2     tuxdemo2
#   NEWYORK       8500	    8510   8520	   8530   B3     tuxdemo3
#   BROKER	      8600	    8610   8620	   8630
#
# TSAM dataserver:  tuxdemo:8988/tsam/dataserver
#

#
*RESOURCES
DOMAINID	BROKER
IPCKEY	43194
#PERM		0660
MAXACCESSERS	100
MAXSERVERS	100
MAXSERVICES	100
MAXCONV		10
SCANUNIT	10
BLOCKTIME	9
LDBAL		Y
#MASTER		SITE1
#MODEL		SHM
MASTER		SITE1,SITE2
DBBLWAIT	2
OPTIONS		LAN,MIGRATE,EXT_MON
MODEL		MP

#
*MACHINES
DEFAULT:
		TUXDIR="/opt/tuxedo/tuxedo12.2.2.0.0"
		TLOGNAME=TLOG
		MAXWSCLIENTS=40

"tuxedo.demo" LMID=SITE1
		APPDIR="/home/tsam/application/brokerapp/site1"
		TLOGDEVICE="/home/tsam/application/brokerapp/site1/TLOG"
		TUXCONFIG="/home/tsam/application/brokerapp/site1/tuxconfig"
		ULOGPFX="/home/tsam/application/brokerapp/site1/ULOG"
		BRTHREADS=N

		
"tuxdemo-2" LMID=SITE2
		APPDIR="/home/tsam/application/brokerapp/site2"
		TLOGDEVICE="/home/tsam/application/brokerapp/site2/TLOG"
		TUXCONFIG="/home/tsam/application/brokerapp/site2/tuxconfig"
		ULOGPFX="/home/tsam/application/brokerapp/site2/ULOG"
		BRTHREADS=N

#
*GROUPS
SYSGRP	LMID=SITE1 GRPNO=10
JLTG	LMID=SITE1 GRPNO=20
GWWSGRP	LMID=SITE1 GRPNO=30 
#GWGRP	LMID=SITE1 GRPNO=40
GWGRP	LMID=SITE2 GRPNO=40
LMSGRP1	LMID=SITE1 GRPNO=50
LMSGRP2	LMID=SITE2 GRPNO=60

#  WEBGRP  LMID=SITE1 GRPNO=70

DEFAULT:	TMSNAME=TMS_ORACLE	TMSCOUNT=2
BROKER1		GRPNO=100  LMID=SITE1
		OPENINFO="Oracle_XA:Oracle_XA+Acc=P/tuxdemo1/tuxdemo1+SqlNet=tuxdemo+SesTm=0+DbgFl=15+LogDir=."

BROKER2		GRPNO=110  LMID=SITE2
		OPENINFO="Oracle_XA:Oracle_XA+Acc=P/tuxdemo1/tuxdemo1+SqlNet=tuxdemo+SesTm=0+DbgFl=15+LogDir=."

#
*NETWORK
SITE1	NADDR="//tuxedo.demo:8641"
        NLSADDR="//tuxedo.demo:3050"
SITE2	NADDR="//tuxedo.demo:8642"
        NLSADDR="//tuxedo.demo:3060"

#
*SERVERS
DEFAULT: RESTART=Y MAXGEN=5 REPLYQ=Y CLOPT="-A"

# Server "BROKER" will be replaced with Java server
BROKER		SRVGRP=BROKER1	SRVID=10 MIN=1 MAX=1
BROKER		SRVGRP=BROKER2	SRVID=10 MIN=1 MAX=1
BRACNT		SRVGRP=BROKER2	SRVID=20
BRHOLDING	SRVGRP=BROKER1	SRVID=30
BRHOLDING	SRVGRP=BROKER2	SRVID=30

#TMJAVASVR	SRVGRP=BROKER1 SRVID=60
#		CLOPT="-A -- -c TJSconfig_oracle.xml"
#		MINDISPATCHTHREADS=2 MAXDISPATCHTHREADS=2
	
BRLIST		SRVGRP=BROKER1	SRVID=40 MIN=1 MAX=1

DMADM       SRVGRP=SYSGRP   SRVID=10
GWADM       SRVGRP=GWGRP    SRVID=30
GWTDOMAIN   SRVGRP=GWGRP    SRVID=50

TMUSREVT SRVGRP=JLTG SRVID=1 CLOPT="-A"	

JSL   SRVGRP=JLTG SRVID=2
      CLOPT="-- -n //tuxedo.demo:8620 -d /dev/tcp -m2 -M4 -x10  "

JREPSVR SRVGRP=JLTG SRVID=20  MAXGEN=3
	CLOPT="-A -- -W -P /home/tsam/application/brokerapp/jrep"
	RESTART=Y REPLYQ=Y GRACE=0

#GWWS configuration
TMMETADATA SRVGRP=GWWSGRP SRVID=800
    CLOPT = "-A -- -f /home/tsam/application/brokerapp/metadata.rps"

GWWS    SRVGRP=GWWSGRP SRVID=900
    CLOPT="-A --  -i GW1"

# ADD SCRIPTING ENGINES HERE
# PHP Engine
#  WEBHNDLR    SRVGRP=WEBGRP   SRVID=1 MIN=5 MAX=15
    #  ENVFILE="WEBHNDLR.env"
# Python Engine
#  SCAHOST     SRVGRP=WEBGRP   SRVID=20 CLOPT="-A -- -c python.server"
# test php reference binding
#  simpserv    SRVGRP=WEBGRP   SRVID=99


WSL	SRVGRP=GWGRP	SRVID=70
	CLOPT="-A -- -n //tuxedo.demo:8610"

#WSL	SRVGRP=GWGRP	SRVID=72
LMS     SRVGRP=LMSGRP1  SRVID=90  CLOPT="-A -- -l tuxedo.demo:7001/tsam -m 100m" RESTART=N


#
#
*SERVICES
DEFAULT:	LOAD=50		AUTOTRAN=Y		TRANTIME=60
BR_OPEN_ACNT	PRIO=40
BR_CLOSE_ACNT	PRIO=40
BR_ADD_HOLDING	PRIO=50
BR_DEL_HOLDING	PRIO=50
BR_BUY_STOCK	PRIO=50
BR_SELL_STOCK	PRIO=50
BR_ACNT_LIST	PRIO=30
BR_ACNT_SUM	PRIO=30
GET_QUOTE       PRIO=30
