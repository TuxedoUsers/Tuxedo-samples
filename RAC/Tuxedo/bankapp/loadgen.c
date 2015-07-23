/*
	This program generates load on the bankapp application.  It generates random deposit, withdrawal,
	and transfer requests.
*/

#include <stdio.h>		/* UNIX */
#include <string.h>		/* UNIX	*/
#include <stdlib.h>
#include <atmi.h>		/* TUXEDO */
#include <Usysfl32.h>
#include <fml32.h>
#undef MAXFLOAT
#include <math.h>		/* UNIX	*/
#include "bankflds.h"		/* FML field table defines */

/* create an account number by simply select one from acctnum1 and one from acctnum2 */
#define NACCT1 10
static char *acctnum1[] = {"10", "20", "30", "40", "50", "60", "70", "80", "90", "100"};
#define NACCT2 20
static char *acctnum2[] = {"000", "001", "002", "003", "004",
			   "005", "006", "007", "008", "009",
			   "010", "011", "012", "013", "014",
			   "015", "016", "017", "018", "019"};


unsigned int rand_interval(unsigned int min, unsigned int max)
{
    int r;
    const unsigned int range = 1 + max - min;
    const unsigned int buckets = RAND_MAX / range;
    const unsigned int limit = buckets * range;

    /* Create equal size buckets all in a row, then fire randomly towards
     * the buckets until you land in one of them. All buckets are equally
     * likely. If you land off the end of the line of buckets, try again. */
    do
    {
        r = rand();
    } while (r >= limit);

    return min + (r / buckets);
}


main(int argc, char *argv[])
{
	TPINIT	*tpinitbuf;
	FBFR32	*fmlbuf;
	int	reqtype;	/* 0=INQUIRY, 1=DEPOSIT, 2=WITHDRAWAL, 3=TRANSFER */
	char	fromacct[7];	/* From account number */
	char	toacct[7];	/* To account number */
	long	acct_id;
	char	samount[10];	/* Amount as a string */
	int	amount;		/* Amount as an int */
	int	acct1, acct2;
	char	*svcname;	/* Name of service to invoke */
	long	len;
	int	i;
	char	statline[256];
	FLDLEN32	maxlen;


	if ((tpinitbuf = (TPINIT *) tpalloc("TPINIT",NULL, sizeof(struct tpinfo_t))) == NULL) {
		(void) fprintf(stderr, "Error allocating TPINIT buffer, %s\n", tpstrerror(tperrno));
		return(1);
	}

	if (tpinit(tpinitbuf) == -1) {
		(void) fprintf(stderr, "Error performing TPINIT, %s\n", tpstrerror(tperrno));
		return(1);
	}

	fmlbuf = (FBFR32 *)tpalloc("FML32", NULL, 2048);
	if (fmlbuf == NULL) {
		(void) fprintf(stderr, "Error allocating FML32 buffer, %s\n", tpstrerror(tperrno));
		return(1);
	}
	i = 0;
	/* Now loop through creating random requests */
	while (1) {
		/* Create the necessary random numbers for toacct */
		acct1 = rand_interval(0, NACCT1 - 1);
		acct2 = rand_interval(0, NACCT2 - 1);
		strcpy(toacct, acctnum1[acct1]);
		strcat(toacct, acctnum2[acct2]);
		acct_id = atol(toacct);
		Finit32(fmlbuf, 2048);
		reqtype = rand_interval(0, 3);
		switch (reqtype) {
		  case 0: /* INQUIRY */
			svcname = "INQUIRY";
			(void) fprintf(stderr, "Adding ACCOUNT_ID = %ld\n", acct_id);
			Fadd32(fmlbuf, ACCOUNT_ID, (char *)&acct_id, 0);
			break;

		  case 1: /* DEPOSIT */
			svcname = "DEPOSIT";
			(void) fprintf(stderr, "Adding ACCOUNT_ID = %ld\n", acct_id);
			Fadd32(fmlbuf, ACCOUNT_ID, (char *)&acct_id, 0);
			/* Need a random amount */
			amount = rand_interval(1, 20000);
			sprintf(samount, "%d", amount);
			(void) fprintf(stderr, "Adding SAMOUNT = %s\n", samount);
			Fadd32(fmlbuf, SAMOUNT, samount, strlen(samount));
			break;

		  case 2: /* WITHDRAWAL */
			svcname = "WITHDRAWAL";
			(void) fprintf(stderr, "Adding ACCOUNT_ID = %ld\n", acct_id);
			Fadd32(fmlbuf, ACCOUNT_ID, (char *)&acct_id, 0);
			/* Need a random amount */
			amount = rand_interval(1, 11000);
			sprintf(samount, "%d", amount);
			(void) fprintf(stderr, "Adding SAMOUNT = %s\n", samount);
			Fadd32(fmlbuf, SAMOUNT, samount, strlen(samount));
			break;

		  case 3: /* TRANSFER */
			svcname = "TRANSFER";
			(void) fprintf(stderr, "Adding ACCOUNT_ID = %ld\n", acct_id);
			Fadd32(fmlbuf, ACCOUNT_ID, (char *)&acct_id, 0);
			/* Need another account */
			acct1 = rand_interval(0, NACCT1 - 1);
			acct2 = rand_interval(0, NACCT2 - 1);
			strcpy(fromacct, acctnum1[acct1]);
			strcat(fromacct, acctnum2[acct2]);
			acct_id = atol(fromacct);
			(void) fprintf(stderr, "Adding ACCOUNT_ID = %ld\n", acct_id);
			Fadd32(fmlbuf, ACCOUNT_ID, (char *)&acct_id, 0);
			/* Need a random amount */
			amount = rand_interval(1, 11000);
			sprintf(samount, "%d", amount);
			(void) fprintf(stderr, "Adding SAMOUNT = %s\n", samount);
			Fadd32(fmlbuf, SAMOUNT, samount, strlen(samount));
			break;
		} /* end of switch */
		/* now make tpcall */
		(void) fprintf(stderr, "Call service %s: ", svcname);
		if (tpcall(svcname, (char *)fmlbuf, 0, (char **)&fmlbuf, &len, 0) == -1) {
			if (tperrno == TPESVCFAIL) {
				maxlen = sizeof(statline);
				Fget32(fmlbuf, STATLIN, 0, statline, &maxlen);
				(void) fprintf(stderr, "%s\n", statline);
			} else {
				(void) fprintf(stderr, "Error making tpcall, %s\n", tpstrerror(tperrno));
			}
		} else {
			(void) fprintf(stderr, "Success\n");
		}
	}
}

