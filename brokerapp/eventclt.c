/*	(c) 2007 BEA Systems, Inc. All Rights Reserved. */


#include <stdio.h>		/* UNIX */
#include <string.h>		/* UNIX */
#include <signal.h>		/* UNIX */
#include <ctype.h>		/* UNIX */

#include <atmi.h>		/* TUXEDO */
#include <userlog.h>	/* TUXEDO */
#include <Uunix.h>		/* TUXEDO */
#include <Usignal.h>	/* TUXEDO */

#ifdef _TMFML32
#include <fml32.h>		/* TUXEDO */
#include <fml1632.h>	/* TUXEDO */
#include <Usysfl32.h>	/* TUXEDO */
#else
#include <fml.h>		/* TUXEDO */
#include <Usysflds.h>	/* TUXEDO */
#endif

#include "brokerflds.h"	/* Broker Fields */
#include "eventflds.h"	/* Events */

#ifdef WIN32
extern int sleep _((unsigned));
#endif


/* Define TRUE and FALSE */

#ifdef TRUE
#undef TRUE
#endif
#define TRUE	1

#ifdef FALSE
#undef FALSE
#endif
#define FALSE	0

static long broker_ev_sub = 0L ; 	/* event subscription handle */

static int  f_sig_recvd ;			/* flag indicating that the signal was rcvd */


/* Handler for unsolicited messages (events) */
static void _TMDLLENTRY unsol_evhndlr _((char *, long, long)) ;

/* Signal handler for SIGINT & SIGTERM signals */
static USIGTYP prockill_handler _((int)) ;	/* See Usignal.h */


#if defined(__STDC__) || defined(__cplusplus)
main(int argc, char *argv[])

#else

main(argc, argv)
int argc;
char *argv[];
#endif

{

char	*eventexpr ;	/* option arg for option -e */
char	*filter ;	/* option arg for option -f */
TPINIT	*tpinitbuf ;	/* tpalloc'd pointer */

	/* Set 'proc_name' to identify client by name in the ULOG */

    if (strrchr(argv[0],'/') != NULL) {
		proc_name = strrchr(argv[0],'/')+1;
	} else {
	    proc_name = argv[0];
	}

    /* Set up defaults  for options (-e, -f) */

    eventexpr = "BROKER_TRANSACTION";
    filter = "";

    /* Alloc a TPINIT buffer for identification purposes.
     * This is not mandatory if no authentication is configured
     */

    tpinitbuf = (TPINIT *) tpalloc("TPINIT", NULL, TPINITNEED(16)) ;

    if (tpinitbuf == (TPINIT *) NULL) {
		(void)fprintf(stderr, "ERROR: Failed for TPINIT buffer, %s\n",
				tpstrerror(tperrno));
		(void)userlog("ERROR: Failed for TPINIT buffer, %s",
				tpstrerror(tperrno));
		return 1;
    }

	(void)strcpy (tpinitbuf->usrname, argv[0]) ;
	(void)strcpy (tpinitbuf->passwd, "") ;
	(void)strcpy (tpinitbuf->cltname, "tpsysadm") ;

    /* Join application */

    if (tpinit(tpinitbuf) == -1) {
		(void)fprintf(stderr, "ERROR: Failed to join application, %s\n",
				tpstrerror(tperrno));
		(void)userlog("ERROR: Failed to join application, %s",
				tpstrerror(tperrno));
		return 2;
    }

    /* the tpinitbuf is no longer needed and may be freed */
    tpfree((char *)tpinitbuf) ;

    /* Prepare to Subscribe to event eventexpr. (default BANK_TLR_WITHDRAWAL)
     * Bank manager would like to be notified in case of large withdrawals.
     */

    /* Set the unsolicited message handler for the event */

    if (tpsetunsol ((void (_TMDLLENTRY *) _((char *, long, long))) unsol_evhndlr) == TPUNSOLERR) {
		(void)fprintf (stderr, "ERROR: tpsetunsol failed: %s\n",
				 tpstrerror (tperrno)) ;
		(void)userlog ("ERROR: tpsetunsol failed: %s", tpstrerror(tperrno));
		tpterm () ;
		return 3 ;
    }

    /* Subscribe to event eventexpr
     * requesting notification via an unsolicited  message handler
     */

    broker_ev_sub = tpsubscribe ( eventexpr,
				    filter,
				    (TPEVCTL *)NULL,
				    TPSIGRSTRT) ;

    if (broker_ev_sub == -1L) {
		(void)fprintf (stderr, "ERROR: tpsubscribe for event %s failed: %s\n",
				eventexpr, tpstrerror(tperrno)) ;
		(void)userlog ("ERROR: tpsubscribe for event %s failed: %s",
				eventexpr, tpstrerror(tperrno)) ;
		tpterm () ;
		return 4 ;
    } else {
		(void)fprintf (stdout, "INFO: Subscribed to event '%s'\n", eventexpr) ;
	}

	/* Catch SIGINT and SIGTERM signals */

    if ((Usignal (SIGINT,  (USIGTYP (*) _((int))) prockill_handler) == SIG_ERR) ||
			(Usignal (SIGTERM, (USIGTYP (*) _((int))) prockill_handler) == SIG_ERR)) {
		perror ("ERROR: Usignal() failed") ;

		/* unsubscribe the subscribed events (clean up) before exit */

		if (tpunsubscribe (broker_ev_sub, TPSIGRSTRT) == -1) {
		    (void)fprintf (stderr, "ERROR: tpunsubscribe failed for %s: %s\n",
			    eventexpr, tpstrerror (tperrno));
	    	(void)userlog ("ERROR: tpunsubscribe failed for %s: %s",
			    eventexpr, tpstrerror (tperrno));
		}

		(void)tpterm () ;
		return 5 ;
    }

    f_sig_recvd = FALSE;	/* loop condition */

    /* Loop checking for messages */

    while (f_sig_recvd == FALSE) {
		/*
	 	* Check for any unsolicited messages. Actually this is needed only
	 	* if notification method configured is DIPIN notification.
	 	*/
		if (tpchkunsol () == -1) {
		    (void)fprintf (stderr, "ERROR: tpchkunsol failed: %s\n",
					    tpstrerror(tperrno)) ;
		    (void)userlog ("ERROR: tpchkunsol failed: %s", tpstrerror(tperrno));
		}


		(void)sleep (5) ;

    } /* while */

    /* Unsubscribe to the subscribed events */

    if (tpunsubscribe (broker_ev_sub, TPSIGRSTRT) == -1) {
		(void)fprintf (stderr, "ERROR: tpunsubscribe failed for %s: %s\n",
			eventexpr, tpstrerror (tperrno));
		(void)userlog ("ERROR: tpunsubscribe failed for %s: %s",
			eventexpr, tpstrerror (tperrno));
    } else {
		(void)fprintf (stdout, "INFO: UnSubscribed to event %s\n", eventexpr) ;
	}

    /* Leave application */

    tpterm() ;

    return 0 ;
}


/* ARGSUSED */

static USIGTYP
#if defined(__STDC__) || defined(__cplusplus)
prockill_handler (int sig)

#else

prockill_handler (sig)
int sig;
#endif

{
    f_sig_recvd = TRUE;	    /* flag indicating that the signal was recvd */

    return ;
}



/* ARGSUSED */

static void
_TMDLLENTRY
#if defined(__STDC__) || defined(__cplusplus)
unsol_evhndlr (char *data, long len, long flags)

#else

unsol_evhndlr (data, len, flags)
char *data ;
long len ;
long flags ;
#endif

{
    (void)fprintf (stdout, "%s:%s\n",
			    Fvals ((FBFR *)data, EVENT_TIME, 0),
			    Fvals ((FBFR *)data, STATUS, 0));

    return ;
}


/* End of file */