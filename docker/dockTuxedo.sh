#!/bin/sh
TMP_CID_FILE=tmp/tuxedo.cid
DOCKER_IMAGE_NAME=oracle/tuxedo
DOCKER_CONTAINER_NAME=tuxadmin

if [ ! -e tmp ]
then
  mkdir tmp
fi

if [ -e "$TMP_CID_FILE" ]
then
  docker kill `cat $TMP_CID_FILE` > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    rm -f $TMP_CID_FILE
  else
    docker rm `cat $TMP_CID_FILE`  > /dev/null 2>&1 && rm $TMP_CID_FILE
  fi
fi

if [ ""$1 = "-attach" ]
then
  ATTACH_DEFAULT_PORT="-p 7001:7001"
fi

# RUN THE DOCKER COMMAND

#docker run -d $ATTACH_DEFAULT_PORT --cidfile $TMP_CID_FILE --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE_NAME /u01/oracle/tux12130/user_projects/domains/base_domain/startWebLogic.sh # > /dev/null 2>&1
docker run -d $ATTACH_DEFAULT_PORT --cidfile $TMP_CID_FILE --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE_NAME echo "Tuxedo" # > /dev/null 2>&1
# EXTRACT THE IP ADDRESS
if [ -n "${ATTACH_DEFAULT_PORT}" ]
then
  WLS_ADMIN_IP=127.0.0.1
else
  WLS_ADMIN_IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $DOCKER_CONTAINER_NAME)
fi

#echo "WebLogic starting... "
#sleep 10
#echo "Open WebLogic Console at http://${WLS_ADMIN_IP}:7001/console"
