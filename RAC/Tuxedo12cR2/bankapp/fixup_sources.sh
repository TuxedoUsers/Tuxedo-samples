#!/bin/bash
#
# Script to fix up the bankapp sample application source files.
patch aud.v <aud.v.patch
patch bankclt.c <bankclt.c.patch
patch bankapp.mk <bankapp.mk.patch
patch ubbshm <ubbshm.patch
patch bankflds <bankflds.patch
patch crbank.sh <crbank.sh.patch
chmod u+x crbank.sh
patch crqueue.sh <crqueue.sh.patch
chmod u+x crqueue.sh
patch populate.sh <populate.sh.patch

