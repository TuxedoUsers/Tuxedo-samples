#
CGFLAG=
#
#
# To use FML32 instead of FML16:
# set FML32 to 32 to use the FML32 commands
# change the ubb files to use FML32 instead of FML and VIEW32 instead of VIEW
FML32=32

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
INSTALL= $(CLAS)

all:	$(INSTALL) Complete

install:	$(INSTALL) Complete

Complete:
	echo "Build complete"

clean:
	rm *.class brokerflds.java bankflds.java eventflds.java	

TJS_BROKER.class: TJS_BROKER.java brokerflds.class bankflds.class eventflds.class
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar TJS_BROKER.java 

brokerflds.class: brokerflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/vmuser/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) brokerflds
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar brokerflds.java

bankflds.class: bankflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/vmuser/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) bankflds
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar bankflds.java

eventflds.class: eventflds
	java -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar:/home/vmuser/ant-1.7.1/lib/ant.jar weblogic.wtc.jatmi.mkfldclass$(FML32) eventflds
	javac -classpath .:$(TUXDIR)/udataobj/tuxj/com.bea.core.jatmi_2.0.0.0.jar:$(TUXDIR)/udataobj/tuxj/com.oracle.tuxedo.tjatmi_12.2.2.0.jar eventflds.java

