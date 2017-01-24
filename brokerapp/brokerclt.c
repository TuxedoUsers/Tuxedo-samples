/*	(c) 2007 BEA Systems, Inc. All Rights Reserved. */

#include <stdio.h>		/* UNIX */
#include <string.h>		/* UNIX */
#include <stdlib.h>
#include <unistd.h>

#include <atmi.h>		/* TUXEDO */
#include <userlog.h>		/* TUXEDO */
#include <fml32.h>		/* TUXEDO */
#include <fml1632.h>		/* TUXEDO */
#include <Usysfl32.h>		/* TUXEDO */
#include "brokerflds.h"		/* broker fields */
#include "bankflds.h"		/* bankapp fields */


/* Define number of options*/
#define NUM_OPT_LIST 3
#define NUM_OPT_SUM 5
#define NUM_OPT_BUY 11
#define NUM_OPT_SELL 11

/*	Prototype definitions for functions */
static int ListAccount(void);
static int AccountSum(char *);
static int BuyStock(char *, char *, float, long);
static int SellStock(char *, char *, float, long);
static int CheckAccount(char *);
static int CheckSymbol(char *, char *);
static int do_tpcall(char *);
static int parse_opt(int , char **, char **, char **, char **, long *, float *);
static void usage(void);

/* Pointer to FML buffer that is used for communication */
static FBFR32 *fbfr32;

/*
 * Main
 */
main(int argc, char **argv)
{
	TPINIT *tpinfo;
	char *service_name = NULL;
	char *brokerage_account = NULL;
	char *symbol = NULL;
	long quantity = 0;
	float price = 0;
	
	/* parse the options */
	if (parse_opt(argc, argv, &service_name, 
				&brokerage_account, &symbol, 
				&quantity, &price) != 0) {
		(void)usage();
		return 1;
	}

	/* Allocate a TPINIT buffer */
	if ((tpinfo = (TPINIT *)tpalloc("TPINIT", NULL, 
					sizeof(struct tpinfo_t))) == (TPINIT *)NULL) {
		(void)fprintf(stderr, "ERROR: tpalloc failed (%s)\n", 
				tpstrerror(tperrno));
		return(1);
	}


	/* Join the Tuxedo System */
	if (tpinit(tpinfo) == -1) {
		(void)fprintf(stderr, "ERROR: tpinit failed (%s)\n", 
				tpstrerror(tperrno));
		return(1);
	}


	/* Allocate the FML buffer used for all communication */
	fbfr32 = (FBFR32 *)tpalloc("FML32", NULL, 1024);
	if (fbfr32 == NULL) {
		(void)fprintf(stderr, "ERROR: tpalloc of FML buffer failed (%s)\n", 
				tpstrerror(tperrno));
		return(1);
	}

	/* Select the service */
	if (strcmp(service_name, "LIST") == 0) {
		ListAccount();
	} else if (strcmp(service_name, "SUM") == 0) {
		AccountSum(brokerage_account);
	} else if (strcmp(service_name, "SELL") == 0) {
		SellStock(brokerage_account, symbol, price, quantity);
	} else if (strcmp(service_name, "BUY") == 0) {
		BuyStock(brokerage_account, symbol, price, quantity);
	}
	

	tpfree((char *)fbfr32);
	tpterm();
	return(0);
	
}

/*
 * Print the usage
 */
static void
usage(void)
{
	(void)fprintf(stderr, "Usage:\n");
	(void)fprintf(stderr, "List Accounts: brokerclt -S LIST\n");
	(void)fprintf(stderr, "Account Summary: brokerclt -S SUM -a ACCOUNT\n");
	(void)fprintf(stderr, "Buy Stock: brokerclt -S BUY -a ACCOUNT -s SYMBOL -n QUANTITY -p PRICE\n");
	(void)fprintf(stderr, "Sell Stock: brokerclt -S SELL -a ACCOUNT -s SYMBOL -n QUANTITY -p PRICE\n");
}

/*
 *	Parse the options from Main
 */
static int
parse_opt(int argc, 
		char **argv, 
		char **p_servce, 
		char **p_account, 
		char **p_symbol, 
		long *p_quantity, 
		float *p_price)
{

	int opt;

	/* Parse options */
	while ((opt = getopt(argc, argv, "S:a:s:n:p:")) != -1) {
		switch (opt) {
			case 'S':
				*p_servce = optarg;
				break;

			case 'a':
				*p_account = optarg;
				break;

			case 'n':
				*p_quantity = atol(optarg);
				break;

			case 'p':
				*p_price = atof(optarg);
				break;
			
			case 's':
				*p_symbol = optarg;
				break;

			default:
				return 1;
		}
	}

	/* validate the params */
	if (*p_servce == NULL)
		return 1;

	if (strcmp(*p_servce, "LIST") == 0) {
		if (argc != NUM_OPT_LIST) {
			return 1;
		}
	} else if (strcmp(*p_servce, "SUM") == 0) {
		if (argc != NUM_OPT_SUM || *p_account == NULL) {
			return 1;
		}
	} else if (strcmp(*p_servce, "BUY") == 0) {
		if (argc != NUM_OPT_BUY || *p_account == NULL || *p_symbol == NULL || 
				*p_quantity == 0 || *p_price == 0) {
			return 1;
		}
	} else if (strcmp(*p_servce, "SELL") == 0) {
		if (argc != NUM_OPT_SELL || *p_account == NULL || *p_symbol == NULL || 
				*p_quantity == 0 || *p_price == 0) {
			return 1;
		}
	} else {
		return 1;
	}

	return 0;
}

/*
 * Get a list of brokerage accounts
 */
static int
ListAccount(void)
{
	FLDOCC32 oc32 = 0;

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));

	/* send a request to the BR_ACNT_LIST service and get the reply */
	if (do_tpcall("BR_ACNT_LIST") == 0) {
		oc32 = Foccur32(fbfr32, BROKERAGE_ACNT);
		(void)fprintf(stdout, "Accounts List:\n");
		while (oc32) {
			(void)fprintf(stdout, "%s\n", Ffind32(fbfr32, BROKERAGE_ACNT, --oc32, 0));
		}
	}

	return 0;
}

/*
 * This function does the tpcall to Tuxedo.
 */
static int
do_tpcall(char *service)
{

	long len;
	char *server_status;

	/* Begin a Global transaction */
	if (tpbegin(30, 0) == -1) {
		(void)fprintf(stderr, "ERROR: tpbegin failed (%s)\n",
			tpstrerror(tperrno));
		return(-1);
	}

	/* Request the service with the user data */
	if (tpcall(service, (char *)fbfr32, 0, (char **)&fbfr32, &len, 0) == -1) {
		if(tperrno== TPESVCFAIL && fbfr32 != NULL &&
		    (server_status=Ffind32(fbfr32,STATUS,0,0)) != 0) {
			/* Server returned failure */
			(void)fprintf(stderr, "%s returns failure (%s)\n",
				service,server_status);
		}
		else {
			(void)fprintf(stderr,
				"ERROR: %s failed (%s)\n", service,
				tpstrerror(tperrno));
		}

		/* Abort the transaction */
		(void) tpabort(0);
		return(-1);
	}

	/* Commit the transaction */
	if(tpcommit(0) < 0) {
		(void)fprintf(stderr, "ERROR: tpcommit failed (%s)\n",
			tpstrerror(tperrno));
		return(-1);
	}
	return(0);
}

/*
 * Get a list of brokerage accounts
 */
static int
AccountSum(char *brokerage_account)
{
	FLDOCC32 oc32 = 0;
	FLDOCC32 i = 0;
	FBFR32 *holding = NULL;

	/* validate the params */
	if (brokerage_account == NULL)
		return 1;
	if (CheckAccount(brokerage_account) != 0) {
		(void)fprintf(stderr, "Account does not exist.\n");
		return 1;
	}

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));
	/* Add the Account number to the buffer */
	(void)Fchg32(fbfr32, BROKERAGE_ACNT, 0, brokerage_account, 0);
	
	/* send a request to the BR_ACNT_SUM service and get the reply */
	if (do_tpcall("BR_ACNT_SUM") == 0) {
		/* if Success the result is in the FML buffer */
		(void)fprintf(stdout, "Brokerage Account: %s\n", 
				brokerage_account);
		(void)fprintf(stdout, "Bank Account: %s\n", 
				(char *)Ffind32(fbfr32, BANK_ACNT, 0, 0));
		(void)fprintf(stdout, "CASH_BALANCE: $%.2f\n", 
				*(float *)Ffind32(fbfr32, CASH_BALANCE, 0, 0));
		(void)fprintf(stdout, "Account Total: $%.2f\n", 
				*(float *)Ffind32(fbfr32, ACNT_TOTAL, 0, 0));

		holding = (FBFR32 *)Ffind32(fbfr32, HOLDINGS, 0, 0);
		if (holding != NULL) {
			oc32 = Foccur32(holding, SYMBOL);
			(void)fprintf(stdout, 
					"   Company    Symbol  Quantity      Cost     Price     TOTAL       Net\n");
			for (; i != oc32; i++) {
				(void)fprintf(stdout, "%10s", (char *)Ffind32(holding, COMPANY, i, 0));
				(void)fprintf(stdout, "%10s", (char *)Ffind32(holding, SYMBOL, i, 0));
				(void)fprintf(stdout, "%10ld", *(long *)Ffind32(holding, QUANTITY, i, 0));
				(void)fprintf(stdout, "%10.2f", *(float *)Ffind32(holding, COST, i, 0));
				(void)fprintf(stdout, "%10.2f", *(float *)Ffind32(holding, PRICE, i, 0));
				(void)fprintf(stdout, "%10.2f", *(float *)Ffind32(holding, TOTAL, i, 0));
				(void)fprintf(stdout, "%10.2f\n", *(float *)Ffind32(holding, NET, i, 0));
			}
		}
	}

	return 0;
}

/* Buy stock */
static int
BuyStock(char *brokerage_account, char *symbol, float price, long quantity)
{
	/* validate the params */
	if (brokerage_account == NULL || symbol == NULL || price <= 0.0 || 
			quantity <= 0)
		return 1;
	if (CheckAccount(brokerage_account) != 0) {
		(void)fprintf(stderr, "Account does not exist.\n");
		return 1;
	}
	if (CheckSymbol(brokerage_account, symbol) != 0) {
		(void)fprintf(stderr, "Symbol does not exist.\n");
		return 1;
	}

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));
	/* Add the params to the buffer*/
	(void)Fchg32(fbfr32, BROKERAGE_ACNT, 0, brokerage_account, 0);
	(void)Fchg32(fbfr32, SYMBOL, 0, symbol, 0);
	(void)Fchg32(fbfr32, PRICE, 0, (char *)&price, 0);
	(void)Fchg32(fbfr32, QUANTITY, 0, (char *)&quantity, 0);
	/* send a request to the BR_BUY_STOCK service and get the reply */
	if (do_tpcall("BR_BUY_STOCK") == 0) {
		/* if Success the result is in the FML buffer */
		(void)fprintf(stdout, "Shares purchased successfully.\n");
		(void)fprintf(stdout, "Account %s bought %ld %s @ $%.2f\n", 
				brokerage_account, quantity, symbol, price);
	}

	return 0;
}

/* Sell stock */
static int
SellStock(char *brokerage_account, char *symbol, float price, long quantity)
{
	/* validate the params */
	if (brokerage_account == NULL || symbol == NULL || price <= 0.0 || 
			quantity <= 0)
		return 1;
	if (CheckAccount(brokerage_account) != 0) {
		(void)fprintf(stderr, "Account does not exist.\n");
		return 1;
	}
	if (CheckSymbol(brokerage_account, symbol) != 0) {
		(void)fprintf(stderr, "Symbol does not exist.\n");
		return 1;
	}

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));
	/* Add the params to the buffer*/
	(void)Fchg32(fbfr32, BROKERAGE_ACNT, 0, brokerage_account, 0);
	(void)Fchg32(fbfr32, SYMBOL, 0, symbol, 0);
	(void)Fchg32(fbfr32, PRICE, 0, (char *)&price, 0);
	(void)Fchg32(fbfr32, QUANTITY, 0, (char *)&quantity, 0);

	/* send a request to the BR_SELL_STOCK service and get the reply */
	if (do_tpcall("BR_SELL_STOCK") == 0) {
		/* if Success the result is in the FML buffer */
		(void)fprintf(stdout, "Shares sold successfully.\n");
		(void)fprintf(stdout, "Account %s sold %ld %s @ $%.2f\n", 
				brokerage_account, quantity, symbol, price);
	}

	return 0;
}

/* Check the brokerage account for existence */
static int
CheckAccount(char *brokerage_account)
{
	FLDOCC32 oc32 = 0;

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));

	/* send a request to the BR_ACNT_LIST service and get the reply */
	if (do_tpcall("BR_ACNT_LIST") == 0) {
		oc32 = Foccur32(fbfr32, BROKERAGE_ACNT);
		while (oc32) {
			if (strcmp(Ffind32(fbfr32, BROKERAGE_ACNT, --oc32, 0), brokerage_account) == 0)
				return 0;
		}
	}

	return 1;
}

/* Check the symbol for existence */
static int
CheckSymbol(char *brokerage_account, char *symbol)
{
	FLDOCC32 oc32 = 0;
	FBFR32 *holding = NULL;

	/* validate the params */
	if (brokerage_account == NULL || symbol == NULL)
		return 1;

	/* Initialize the FML buffer */
	Finit32(fbfr32, (FLDLEN32)Fsizeof32(fbfr32));
	/* Add the Account number to the buffer */
	(void)Fchg32(fbfr32, BROKERAGE_ACNT, 0, brokerage_account, 0);
	
	/* send a request to the BR_ACNT_SUM service and get the reply */
	if (do_tpcall("BR_ACNT_SUM") == 0) {
		/* if Success the result is in the FML buffer */
		holding = (FBFR32 *)Ffind32(fbfr32, HOLDINGS, 0, 0);
		if (holding != NULL) {
			oc32 = Foccur32(holding, SYMBOL);
			while (oc32) {
				if (strcmp(Ffind32(holding, SYMBOL, --oc32, 0), symbol) == 0)
					return 0;
			}
		}
	}

	return 1;
}
