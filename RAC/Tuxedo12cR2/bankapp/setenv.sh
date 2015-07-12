. ${TUXDIR}/tux.env
export APPDIR=~/bankapp
export PATH=${APPDIR}:$PATH
export LD_LIBRARY_PATH=${TUXDIR}/lib:${LD_LIBRARY_PATH}
unset LIBPATH
unset SHLIB_PATH
export ENVFILE=${APPDIR}/ENVFILE
export FIELDTBLS=Usysflds,bankflds,creditflds,eventflds
export FIELDTBLS32=Usysfl32,bankflds,creditflds,eventflds,evt_mib,tpadm
export FLDTBLDIR=${TUXDIR}/udataobj:${APPDIR}
export FLDTBLDIR32=${TUXDIR}/udataobj:${APPDIR}
NADDR=
NDEVICE=
NLSADDR=
export TLOGDEVICE=${APPDIR}/TLOG
export TUXCONFIG=${APPDIR}/tuxconfig
export ULOGPFX=${APPDIR}/ULOG
UNAME=
export VIEWFILES=aud.V
export VIEWFILES32=aud.V,mib_views,tmib_views
export VIEWDIR=${TUXDIR}/udataobj:${APPDIR}
export VIEWDIR32=${TUXDIR}/udataobj:${APPDIR}
export QMCONFIG=${APPDIR}/qdevice
