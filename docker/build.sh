#!/bin/bash

echo "====================="

if [ ! -e tuxedo121300_64_Linux_01_x86.zip ]
then
  echo "Download the Tuxedo 12cR2 ZIP Distribution and"
  echo "drop the file tuxedo121300_64_Linux_01_x86.zip in this folder before"
  echo "building this Tuxedo Docker container!"
  exit 
fi

MD5="7194e8711a257951211185b2280bedd6  tuxedo121300_64_Linux_01_x86.zip"
MD5_CHECK="`md5sum tuxedo121300_64_Linux_01_x86.zip`"

if [ "$MD5" != "$MD5_CHECK" ]
then
  echo "MD5 does not match! Download again!"
  exit
fi

echo "====================="

docker build -t oracle/tuxedo .
if [ "$?" = "0" ]
    then
	echo ""
	echo "Tuxedo Docker image is ready to be used. To start, run 'dockTuxedo.sh'"
    else
	echo "Build of Tuxedo Docker image failed."
fi

