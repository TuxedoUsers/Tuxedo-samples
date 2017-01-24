#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <iomanip>
#include <ctype.h>
#include "atmi.h"
#define _TMFML32
#ifdef _TMFML32
#include "Usysfl32.h"
#include "fml32.h"
#include "fml1632.h"
#else
#include "Usysflds.h"
#include "fml.h"
#endif
#include "userlog.h"
#include "bankflds.h"
#include "brokerflds.h"

using namespace std;

/* Pointer to FML buffer that is used for communication */
static FBFR	*fbfr;

static int 	ListAccount(void);
static int	BuyStock(char *, char *, long, float); 
static int      SellStock(char *, char *, long, float);
static int	getAccountSummary(char *account);
static void     (_TMDLLENTRY unsolfcn)(char *, long, long);
static int      do_tpcall(char *);
static void     usage();
static int      check_account_id(char *);
static int 	check_symbol(char *, char *);


char * info = "\
Usage:\n\
List: brokerclt -S LIST\n\
Account Summary: brokerclt -S SUM -a ACCOUNT_ID\n\
Buy Stock: brokerclt -S BUY -a ACCOUNT_ID -s SYMBOL -n QUANTITY -p PRICE\n\
Sell Stock: brokerclt -S SELL -a ACCOUNT_ID -s SYMBOL -n QUANTITY -p PRICE\n";

/*
 * Main
 */
#if defined(__STDC__) || defined(__cplusplus)
int main(int argc, char * argv[])
#else
int main(argc, argv)
int argc;
char * argv[];
#endif
{
	TPINIT *tpinfop;
	char * 	account;
	char * 	symbol;
	long	quantity;
	float 	price;

	/* Allocate a TPINIT buffer */
	if ((tpinfop = (TPINIT *)tpalloc("TPINIT", NULL,
		sizeof(struct tpinfo_t))) == (TPINIT *)NULL) {
		(void)fprintf(stderr, "ERROR: tpalloc failed (%s)\n",
			tpstrerror(tperrno));
		return(1);
	}

	/* Enter user information */
	(void)strcpy(tpinfop->usrname, "Bill");
	(void)strcpy(tpinfop->cltname, "bankclt");
	(void)strcpy(tpinfop->passwd, "mypasswd");
	tpinfop->flags = TPU_DIP;
	tpinfop->datalen = 0;
	tpinfop->data = 0;

	/* Join the Tuxedo System */
	if (tpinit(tpinfop) == -1) {
		(void)fprintf(stderr, "ERROR: tpinit failed (%s)\n",
			tpstrerror(tperrno));
		return(1);
	}

	/* Allocate the FML buffer used for all communication */
	fbfr = (FBFR *)tpalloc(FMLTYPE, NULL, 1024);
	if (fbfr == NULL) {
		(void)fprintf(stderr,
			"ERROR: tpalloc of FML buffer failed (%s)\n",
			tpstrerror(tperrno));
		return(1);
	}

	/* Set an unsolicited message handler */
	if(tpsetunsol(unsolfcn) == TPUNSOLERR) {
		(void)fprintf(stderr, "ERROR: tpsetunsol failed (%s)\n",
			tpstrerror(tperrno));
		return(1);
	}
	/*parse the options in argv and argc*/
	if (getopt(argc,argv,"S:") != -1 ){
		if((strcmp(optarg,"LIST")) == 0){
			/*Usage:./bankclt -S LIST*/
			ListAccount();
		}
		else if((strcmp(optarg,"BUY")) == 0){
			/*./bankclt -S BUY -a ACCOUNT_ID -s SYMBOL -n QUANTITY -p PRICE*/
			if (getopt(argc,argv,"a:") != -1 )	
				account = optarg;
			else 
				usage();
			if (getopt(argc,argv,"s:") != -1 )
				symbol = optarg;
			else 
				usage();
			if (getopt(argc,argv,"n:") != -1 )
				quantity = atol(optarg);
			else 
				usage();
			if (getopt(argc,argv,"p:") != -1 )
				price = atof(optarg);
			else
				usage();
			
			BuyStock(account, symbol, quantity, price);

		}
		else if((strcmp(optarg,"SELL")) == 0){
                        /*./bankclt -S SELL -a ACCOUNT_ID -s SYMBOL -n QUANTITY -p PRICE*/
                        if (getopt(argc,argv,"a:") != -1 )
                                account = optarg;
                        else
                                usage();
                        if (getopt(argc,argv,"s:") != -1 )
                                symbol = optarg;
                        else
                                usage();
                        if (getopt(argc,argv,"n:") != -1 )
                                quantity = atol(optarg);
                        else
                                usage();
                        if (getopt(argc,argv,"p:") != -1 )
                                price = atof(optarg);
                        else
                                usage();

                        SellStock(account, symbol, quantity, price);

		}
		else if((strcmp(optarg,"SUM")) == 0){
			/*./bankclt -S SUM -a ACCOUNT_ID*/
                        if (getopt(argc,argv,"a:") != -1 )
                                account = optarg;
                        else
                                usage();

			getAccountSummary(account);	
		}
		else
			usage();
	}
	else
		usage();
	tpfree((char *)fbfr);
	tpterm();
	return(0);
}

static int
ListAccount(void)
{
     FLDOCC32 oc = 0;

     /* Initialize the FML buffer */
     Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

     if (do_tpcall("BR_ACNT_LIST") == 0) {
         oc = Foccur32(fbfr, BROKERAGE_ACNT);
         cout << "Account list:" << endl;
         while (oc) {
		cout << Ffind32(fbfr, BROKERAGE_ACNT, --oc, 0) << endl;
         }
     }

     return 0;
}

static int 
BuyStock(char * account, char * symbol, long quantity, float price)
{
        if (check_account_id(account) != 0) {
		cout << "Account does not exist" << endl;
                exit(1);
	}
        /* Initialize the FML buffer */
        Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

        (void) Fchg32(fbfr, BROKERAGE_ACNT, 0, account, 0);
        (void) Fchg32(fbfr, SYMBOL, 0, symbol, 0);
        (void) Fchg32(fbfr, QUANTITY, 0, (char *)&quantity, 0);
        (void) Fchg32(fbfr, PRICE, 0, (char *)&price, 0);

        if (do_tpcall("BR_BUY_STOCK") == 0) {
		cout << "Buy status: Success" << endl;
		cout << "Account " << account << " "
		     << "bought " << quantity << " "
		     << symbol << " " << price << endl;
/**
                cout << "Shares purchased successfully." << endl;
		cout << "Quantity: " << *(long *)Ffind32(fbfr, QUANTITY, 0, 0) << endl;
		cout << "Price: $" << *(float *)Ffind32(fbfr, PRICE, 0, 0) << endl;
**/
        }

	return(1);
}
static int
SellStock(char * account, char * symbol, long quantity, float price)
{
        if (check_account_id(account) != 0) {
                cout << "Account does not exist" << endl;
                exit(1);
        }
        if (check_symbol(account, symbol) != 0) {
                cout << "Symbol does not exist" << endl;
                exit(1);
        }


        /* Initialize the FML buffer */
        Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

        (void) Fchg32(fbfr, BROKERAGE_ACNT, 0, account, 0);
        (void) Fchg32(fbfr, SYMBOL, 0, symbol, 0);
        (void) Fchg32(fbfr, QUANTITY, 0, (char *)&quantity, 0);
        (void) Fchg32(fbfr, PRICE, 0, (char *)&price, 0);

        if (do_tpcall("BR_SELL_STOCK") == 0) {
                cout << "Sell status: Success" << endl;
                cout << "Account " << account << " "
                     << "sold " << quantity << " "
                     << symbol << " " << price << endl;
/**
                cout << "Shares sold successfully." << endl;
                cout << "Quantity: " << *(long *)Ffind32(fbfr, QUANTITY, 0, 0) << endl;
                cout << "Price: $" << *(float *)Ffind32(fbfr, PRICE, 0, 0) << endl;
**/
        }

        return(1);
}

static int
getAccountSummary(char *account)
{
        if (check_account_id(account) != 0) {
                cout << "Account does not exist" << endl;
                exit(1);
        }

	FLDOCC32 oc = 0;
	FLDOCC32 i = 0;
	FBFR32 *holding = NULL;


	/* Initialize the FML buffer */
	Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

	(void)Fchg32(fbfr, BROKERAGE_ACNT, 0, account, 0);
	
	if (do_tpcall("BR_ACNT_SUM") == 0) {
		cout << "Brokerage Account:\t" << account << endl;
		cout << "Bank Account:\t\t" << (char *)Ffind32(fbfr, BANK_ACNT, 0, 0) << endl;
		cout << "CASH_BALANCE:\t\t" << std::fixed << setprecision(2) 
		     << *(float *)Ffind32(fbfr, CASH_BALANCE, 0, 0) << endl;
		cout << "Account Total:\t\t" << std::fixed << setprecision(2) 
		     << *(float *)Ffind32(fbfr, ACNT_TOTAL, 0, 0) << endl;
		cout << endl;

		holding = (FBFR32 *)Ffind32(fbfr, HOLDINGS, 0, 0);
		if (holding != NULL) {
			oc = Foccur32(holding, SYMBOL);
			cout << "Company\t\tSymbol\tQuantity\tCost\tPrice\tTOTAL\t\tNet" << endl;
			for (i; i != oc; i++) {
				cout << (char *)Ffind32(holding, COMPANY, i, 0)
				     << "\t\t" << (char *)Ffind32(holding, SYMBOL, i, 0)
				     << "\t" << *(long *)Ffind32(holding, QUANTITY, i, 0)
				     << "\t\t" << std::fixed << setprecision(2) << *(float *)Ffind32(holding, COST, i, 0)
				     << "\t" << std::fixed << setprecision(2) << *(float *)Ffind32(holding, PRICE, i, 0)
				     << "\t" << std::fixed << setprecision(2) << *(float *)Ffind32(holding, TOTAL, i, 0)
				     << "\t" << std::fixed << setprecision(2) << *(float *)Ffind32(holding, NET, i, 0)
				     << endl;
			}
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
	if (tpcall(service, (char *)fbfr, 0, (char **)&fbfr, &len, 0) == -1) {
		if(tperrno== TPESVCFAIL && fbfr != NULL &&
		    (server_status=Ffind32(fbfr,STATLIN,0,0)) != 0) {
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
 * This is the function that gets called when a unsolicited message is received
 */
void _TMDLLENTRY
unsolfcn(char *inbuf, long len, long flags)
{
	char buftype[9];

	len = len; /* UNUSED */
	flags = flags; /* UNUSED */
	/* Get the buffer type */
	if(tptypes(inbuf, (char *)buftype, NULL) == -1) {
		(void)fprintf(stderr, "ERROR: tptypes() failed (%s)\n",
			tpstrerror(tperrno));
		return;
	}
	/* Only understand the STRING buffer */
	if(strcmp(buftype, "STRING") != 0) {
		(void)fprintf(stderr, "Unsupported Buffer Type %s\n", buftype);
		return;
	}
	/* print out the message */
	(void)fprintf(stdout, "\n\nUnsolicited message received:%s\n\n", inbuf);
	(void)fflush(stdout);
	return;
}

void usage()
{
	cout << info << endl;
	exit(1);
}
/*
 *	Check account
 */
static int
check_account_id(char * account)
{
	FLDOCC32 oc = 0;

	/* Initialize the FML buffer */
	Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

	if (do_tpcall("BR_ACNT_LIST") == 0) {
		oc = Foccur32(fbfr, BROKERAGE_ACNT);
		while (oc) {
			if (strcmp(Ffind32(fbfr, BROKERAGE_ACNT, --oc, 0), account) == 0)
				return 0;
		}
	}

	return 1;
}

static int 
check_symbol(char * account, char * symbol)
{

	FLDOCC32 oc = 0;
	FBFR32 *holding = NULL;

	/* Initialize the FML buffer */
	Finit32(fbfr, (FLDLEN32)Fsizeof32(fbfr));

	(void)Fchg32(fbfr, BROKERAGE_ACNT, 0, account, 0);
	
	if (do_tpcall("BR_ACNT_SUM") == 0) {
		holding = (FBFR32 *)Ffind32(fbfr, HOLDINGS, 0, 0);
		if (holding != NULL) {
			oc = Foccur32(holding, SYMBOL);
			while (oc) {
				if (strcmp(Ffind32(holding, SYMBOL, --oc, 0), symbol) == 0)
					return 0;
			}
		}
	}
        return 1;

}
