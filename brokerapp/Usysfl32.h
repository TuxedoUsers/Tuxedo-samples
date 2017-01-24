/*
        Copyright (c) 2012 Oracle, Inc.
        All rights reserved

        THIS IS UNPUBLISHED PROPRIETARY
        SOURCE CODE OF ORACLE, Inc.
        The copyright notice above does not
        evidence any actual or intended
        publication of such source code.
*/

/*	Copyright (c) 1984 AT&T
	All rights reserved

       /units2/units/src/tuxedo/include/s.Usysflds
       Usysflds     40.1 
*/

#ifndef NOWHAT
static	char h_Usysflds[] = "@(#) tuxedo/include/Usysflds	$Revision: 1.12 $";
#endif

/* #ident	"@(#) tuxedo/include/Usysflds	$Revision: 1.12 $" */

/*	DEFINITIONS NEEDED BY USER APPLICATION PROGRAMS.

	Warning: This file should not be changed in any
	way, doing so will destroy the compatibility with TUXEDO programs
	and libraries.
*/
/*	SYSTEM RESERVED FIELD ENTRIES	*/
/*	fname	fldid            */
/*	-----	-----            */
#define	INITMSK	((FLDID32)167772161)	/* number: 1	 type: string */
#define	CURSID	((FLDID32)33554434)	/* number: 2	 type: long */
#define	CURSOC	((FLDID32)33554435)	/* number: 3	 type: long */
#define	LEVKEY	((FLDID32)167772164)	/* number: 4	 type: string */
#define	STATLIN	((FLDID32)167772165)	/* number: 5	 type: string */
#define	FORMNAM	((FLDID32)167772166)	/* number: 6	 type: string */
#define	UPDTMOD	((FLDID32)7)	/* number: 7	 type: short */
#define	SRVCNM	((FLDID32)167772168)	/* number: 8	 type: string */
#define	NEWFORM	((FLDID32)167772169)	/* number: 9	 type: string */
#define	CHGATTS	((FLDID32)201326602)	/* number: 10	 type: carray */
#define	USYS1FLD	((FLDID32)167772171)	/* number: 11	 type: string */
#define	USYS2FLD	((FLDID32)167772172)	/* number: 12	 type: string */
#define	USYS3FLD	((FLDID32)167772173)	/* number: 13	 type: string */
#define	USYS4FLD	((FLDID32)201326606)	/* number: 14	 type: carray */
#define	USYS5FLD	((FLDID32)201326607)	/* number: 15	 type: carray */
#define	USYS6FLD	((FLDID32)201326608)	/* number: 16	 type: carray */
#define	DESTSRVC	((FLDID32)167772177)	/* number: 17	 type: string */
#define	MODS	((FLDID32)201326610)	/* number: 18	 type: carray */
#define	VALONENTRY	((FLDID32)167772179)	/* number: 19	 type: string */
#define	EVT_MONEVTNONTXNUM	((FLDID32)33554483)	/* number: 51	 type: long */
#define	EVT_MONEVTTXNUM	((FLDID32)33554484)	/* number: 52	 type: long */
#define	EVT_MONEVTSVCNUM	((FLDID32)33554485)	/* number: 53	 type: long */
#define	EVT_MONEVTUNSOLNUM	((FLDID32)33554486)	/* number: 54	 type: long */
#define	EVT_MONEVTQUENUM	((FLDID32)33554487)	/* number: 55	 type: long */
#define	EVT_MONEVTCMDNUM	((FLDID32)33554488)	/* number: 56	 type: long */
#define	EVT_MONEVTULOGNUM	((FLDID32)33554489)	/* number: 57	 type: long */
#define	EVT_CROSSDOMAINNAME	((FLDID32)167772218)	/* number: 58	 type: string */
#define	TUX_RTNCHAR	((FLDID32)67108935)	/* number: 71	 type: char */
#define	TUX_RTNSHORT	((FLDID32)72)	/* number: 72	 type: short */
#define	TUX_RTNLONG	((FLDID32)33554505)	/* number: 73	 type: long */
#define	TUX_RTNFLOAT	((FLDID32)100663370)	/* number: 74	 type: float */
#define	TUX_RTNDOUBLE	((FLDID32)134217803)	/* number: 75	 type: double */
#define	BQCMD	((FLDID32)167772241)	/* number: 81	 type: string */
#define	TPMQ_ADAPTER_ERR	((FLDID32)167772251)	/* number: 91	 type: string */
#define	TPMQ_ADAPTER_ERR_CODE	((FLDID32)167772252)	/* number: 92	 type: string */
#define	TPMQ_APP_ERR	((FLDID32)167772253)	/* number: 93	 type: string */
