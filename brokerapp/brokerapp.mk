#	(c) 2007 BEA Systems, Inc. All Rights Reserved.

#
# ORACLE definitions
#
SUF=.pc
ORACLE_USER=tuxdemo1/tuxdemo1

#
#	ANAME -- Name of this application (e.g. brokerapp).
#
ANAME = brokerapp

#
#	CNAME -- Name of this component (e.g. engine).
#
CNAME = apps

#
#	MODE -- mode used to install targets.
MODE = 0444

#
#	PR -- name of command used to print source listings.
#	By default pr(1) is used; a good substitute is cpr(1).
#
PR = pr

#
#	PRFLAGS -- Flags for $(PR) command.
#
PRFLAGS =

#
# Root directory of TUXEDO System.  This file must either be edited to set
# this value correctly, or the correct value must be passed via "make -f
# brokerapp.mak TUXDIR=/correct/TUXDIR", or the build of brokerapp will fail.
#
# TUXDIR=$(TUXDIR)

#
# Directory where the brokerapp application source and executables live.
# This file must either be edited to set this value correctly, or the
# correct value must be passed via "make -f brokerapp.mak
# APPDIR=/correct/appdir", or the build of brokerapp will fail.
#

#
#
# TUXEDO's include directory
#
INCDIR=$(TUXDIR)/include
#
# Library directory
#
LIBDIR=$(TUXDIR)/lib
SUF=.a
DSUF=.a
PRE=$(LIBDIR)/lib
LIBES=	$(LIBDIR)/libtux$(DSUF) \
	$(LIBDIR)/libbuft$(DSUF) $(LIBDIR)/libengine$(DSUF) \
	$(LIBDIR)/libfml$(DSUF)
#
# Resource Manager
#
RM=Oracle_XA
#
#
CGFLAG=
#
#
# To use FML32 instead of FML16:
# set FML32 to 32 to use the FML32 commands
# set DFML32 to -D_TMFML32
# set TMTYPESW to tmtypesw.o, copy $TUXDIR/lib/tmtypesw.c to this directory
# change the ubb files to use FML32 instead of FML and VIEW32 instead of VIEW
FML32=32
DFML32=-D_TMFML32
TMTYPESW=
#
# C compiler flags:  enable TUXEDO System Distributed Transaction
# Processing, search for C header files in TUXEDO's include directory
#
CFLAGS= -DNOWHAT=1 -I$(INCDIR) $(CGFLAG) $(DFML32)
#
# Lint program
#
LINT=lint
#
# Directory in which to find TUXEDO executables for use in the make process.
# It is called cross-compiler bin directory because when cross-compiling,
# this value may be something other than $(TUXDIR)/bin
#
XCBINDIR=$(TUXDIR)/bin

#
# Shell scripts to be created
#

UFILES= \
	crbroker.sh

#
# Field header files to create
#
HEADERS = \
	brokerflds.h
	
#
# C executable files to create
#
OBJS = \
	BRACNT \
	BRHOLDING \
	BRLIST \
	BROKER \
	eventclt

#
# List of all the source files in brokerapp
#
SRC = \
	BRACNT.pc \
	BRHOLDING.pc \
	BRLIST.pc \
	BROKER.pc \
	util.pc \
	brokerflds \
	brokervar \
	appinit.c \
	eventclt.c \
	FILES \
	README \
	crbroker.sh \
	crbrokerdl1.ora \
	crbrokertab.ora

#
# C functions 
#
CFUNC = \
	BRACNT.c \
	BRHOLDING.c \
	BRLIST.c \
	BROKER.c \
	util.c \
	eventclt.c

#
# C functions that are generated from embedded SQL programs
#
CLFUNC = \
	BRACNT.c \
	BRHOLDING.c \
	BRLIST.c \
	BROKER.c \
	util.c

#
# Object files (.o)
#
COBJ =	\
	BRACNT.o \
	BRHOLDING.o \
	BRLIST.o \
	BROKER.o \
	util.o \
	appinit.o \
	eventclt.o

#
## class files (.class)
#
CLAS = \
	   TJS_BROKER.class \
	   brokerflds.class \
	   bankflds.class \
	   eventflds.class

#
# Exhaustive list of targets to be made
#
INSTALL= $(HEADERS) $(CLFUNC) $(OBJS) $(CLAS)

all:	$(INSTALL) Complete

install:	$(INSTALL) Complete

Complete:
	@echo $(ANAME) processing complete

#
# Rule for linting source
#
lint:
	-LIBDIR= $(LINT) $(LINTOPTS) -DNOWHAT -I$(INCDIR) $(CFUNC)

# Rule for cleaning out generated files
#
#clean:
#	for %%i in ($(SCRIPTS) $(HEADERS) $(CLFUNC) \
#	$(OBJS) $(COBJ) $(SOBJ)) \
#	do if exist %%i rm %%i
clean:
	rm *.o  *.class brokerflds.h	
#
#	clobber -- Should remove everything which was installed
#	(i.e., inverse of install).
#
clobber:	clean
	@echo off & for %%i in ($(INSTALL)) do if exist %%i del %%i

#
#	print -- Should produce a complete source listing of the
#	files in the directory.
#
print::
	@$(PR) $(PRFLAGS) $(SRC)

#
#	list -- Should produce a listing of every source file prepended
#	with the component and sub-component name.
#
list::
	@echo off & for %%i in ($(SRC)) do echo $(CNAME)/$(ANAME)/%%i

#
# This section contains rules for building brokerapp servers
# 
BRACNT:	BRACNT.o appinit.o util.o $(LIBES) $(TMTYPESW)
	(set CFLAGS="$(CFLAGS)") & (set TUXDIR=$(TUXDIR)) &\
	$(XCBINDIR)/buildserver -r $(RM) \
		-s BR_OPEN_ACNT -s BR_CLOSE_ACNT -s BR_CHECK_ACNT \
		-o BRACNT -f BRACNT.o \
		-f appinit.o -f util.o -f "$(TMTYPESW)"

BRHOLDING:	BRHOLDING.o appinit.o util.o $(LIBES) $(TMTYPESW)
	(set CFLAGS="$(CFLAGS)") & (set TUXDIR=$(TUXDIR)) &\
	$(XCBINDIR)/buildserver -r $(RM) \
		-s BR_ADD_HOLDING -s BR_DEL_HOLDING \
		-o BRHOLDING -f BRHOLDING.o \
		-f appinit.o -f util.o -f "$(TMTYPESW)"

BRLIST:	BRLIST.o appinit.o util.o $(LIBES) $(TMTYPESW)
	(set CFLAGS="$(CFLAGS)") & (set TUXDIR=$(TUXDIR)) &\
	$(XCBINDIR)/buildserver -r $(RM) \
		-s BR_ACNT_LIST -s BR_ACNT_SUM -s GET_QUOTE -s POST_EVENT\
		-o BRLIST -f BRLIST.o -f appinit.o -f util.o -f "$(TMTYPESW)"

BROKER:	BROKER.o appinit.o util.o $(LIBES) $(TMTYPESW)
	(set CFLAGS="$(CFLAGS)") & (set TUXDIR=$(TUXDIR)) &\
	$(XCBINDIR)/buildserver -t -r $(RM) \
		-s BR_BUY_STOCK -s BR_SELL_STOCK \
		-o BROKER -f BROKER.o \
		-f appinit.o -f util.o -f "$(TMTYPESW)"

eventclt:	eventclt.o $(LIBES)
	(set TUXDIR=$(TUXDIR)) & $(XCBINDIR)/buildclient -o eventclt -f eventclt.o

TJS_BROKER.class: TJS_BROKER.java brokerflds.class bankflds.class eventflds.class
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar TJS_BROKER.java

brokerflds.class: brokerflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/tsam/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) brokerflds 
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar brokerflds.java

bankflds.class: bankflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/tsam/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) bankflds
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar bankflds.java

eventflds.class: eventflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/tsam/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) eventflds
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar eventflds.java
	
#
# Rule for creating field header file
#
brokerflds.h:	brokerflds 
	$(XCBINDIR)/mkfldhdr$(FML32) brokerflds
#

.SUFFIXES:	.v .V .pc .c .o .sh

#
# Rule for creating C programs from embedded SQL programs
#
.pc.c:
	proc include=/usr/include/oracle/11.2/client \
	include=$(TUXDIR)/include -DANSI_PRO_C mode=ansi code=ansi_c \
	ireclen=132 oreclen=132 select_error=no sqlcheck=limited \
	userid=$(ORACLE_USER) iname=$<

#
# Rule for creating object files from C programs
#
.c.o:
	$(CC) $(CFLAGS) -c $*.c

#
# Rule for creating object files from embedded SQL programs
#
.pc.o:
	proc include=/usr/include/oracle/11.2/client \
	include=$(TUXDIR)/include -DANSI_PRO_C mode=ansi code=ansi_c \
	ireclen=132 oreclen=132 select_error=no sqlcheck=limited \
	userid=$(ORACLE_USER) iname=$<
	$(CC) $(CFLAGS) -c $*.c


# --*--DEPENDENCIES--*--

BRACNT.o BRHOLDING.o BRLIST.o BROKER.o:	brokerflds.h
