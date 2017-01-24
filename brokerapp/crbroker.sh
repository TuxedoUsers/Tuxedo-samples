#    (c) 2007 BEA Systems, Inc. All Rights Reserved.

# Create Oracle Tables for a brokerapp Database
#    -  $1  is an ORACLE username/password combination, e.g. scott/tiger
#    -  $2  is the name of the database, e.g. dl1

# ORACLE_SID=%2
# export ORACLE_SID

#sqlplus $1 @crbroker$2.ora
sqlplus tuxdemo1/tuxdemo1@XE @crbrokerorcl.ora 
