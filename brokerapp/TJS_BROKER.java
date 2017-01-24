
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.text.SimpleDateFormat;
import java.util.Date;

import weblogic.wtc.jatmi.Ferror;
import weblogic.wtc.jatmi.FmlKey;
import weblogic.wtc.jatmi.TypedBuffer;
import weblogic.wtc.jatmi.TypedFML32;

import com.oracle.tuxedo.tjatmi.TPSVCINFO;
import com.oracle.tuxedo.tjatmi.TuxATMIReply;
import com.oracle.tuxedo.tjatmi.TuxATMITPException;
import com.oracle.tuxedo.tjatmi.TuxAppContext;
import com.oracle.tuxedo.tjatmi.TuxException;
import com.oracle.tuxedo.tjatmi.TuxedoJavaServer;
import com.oracle.tuxedo.tjatmi.rm.TuxATMIRMException;



public class TJS_BROKER extends TuxedoJavaServer{
    
    private FmlKey STATUS = new FmlKey(brokerflds.STATUS, 0);
    private FmlKey BROKERAGE_ACNT = new FmlKey(brokerflds.BROKERAGE_ACNT, 0);
    private FmlKey SYMBOL = new FmlKey(brokerflds.SYMBOL, 0);
    private FmlKey QUANTITY = new FmlKey(brokerflds.QUANTITY, 0);
    private FmlKey PRICE = new FmlKey(brokerflds.PRICE, 0);
    private FmlKey ACCOUNT_ID = new FmlKey(bankflds.ACCOUNT_ID, 0);
    private FmlKey SAMOUNT = new FmlKey(bankflds.SAMOUNT, 0);
    private FmlKey SBALANCE = new FmlKey(bankflds.SBALANCE, 0);
    private FmlKey EVENT_NAME = new FmlKey(eventflds.EVENT_NAME, 0);
    private FmlKey EVENT_TIME = new FmlKey(eventflds.EVENT_TIME, 0);
    
    
    private TuxAppContext   myAppCtxt;

    public TJS_BROKER()
    {
        return;
    }

    public int tpsvrinit() throws TuxException
    {
        System.out.println("TJS_BROKER initialized.");
        return 0;
    }

    public void tpsvrdone()
    {
        System.out.println("TJS_BROKER exit.");
        return;
    }

    public void BuyStock(TPSVCINFO rqst) throws TuxException, TuxATMITPException {
        TypedFML32      rqstDatas;
        TypedFML32      reqfb;
        Connection      connDB = null;
        Statement       stmtDB = null;
        String          stmtSQL;
        ResultSet       rs;
        TuxATMIReply    myTuxReply;
        long            flags = TPSIGRSTRT;
        String          transaction = null;
        String          error = null;
        boolean         failed = false;
        boolean         insert;
        int             trnLvl, trnStrtInSVC = 0, trnRtn;
        long            trnFlags = 0;
        
        Long      br_account_id;
        String    symbol = null;
        Long      quantity = null;
        Long      account_id = null;
        Long      volume = null;
        Float     avg_price = null;
        Float     new_price = null;
        String    amts = null;
        String    db_amts = null;
        Float     db_bal = null;
        Long      newquantity = null;
        Float     newprice = null;
        
        
        myAppCtxt =getTuxAppContext();
	                       myAppCtxt.userlog("JAVA-INFO: EnteringTJS_BROKER.BuyStock().");

        
        /* TODO:
         * <SUB 6> use TuxAppContext.userlog() to print a user log into Tuxedo ULOG.
         */
        
        // Get user data
        rqstDatas = (TypedFML32)rqst.getServiceData();
        
        try{
            /* Setup global transaction if needed */
            trnStrtInSVC = 0;
            trnLvl = myAppCtxt.tpgetlev();
            if (0 == trnLvl) {
                /* the call is not in a transaction, start one ... */
                long trnTime = 6000;
                myAppCtxt.userlog("JAVA-INFO: Start a transaction...");
                trnRtn = myAppCtxt.tpbegin(30, 0);
                myAppCtxt.userlog("JAVA-INFO: tpbegin return " + trnRtn);
                trnStrtInSVC = 1;
            }
            
            /* Pre-set status code of the return buffer */

            rqstDatas.Fchg(STATUS, "Shares Purchased");
            
            transaction = "BUY";
        

            /*
            * Get all values for service request from fielded buffer
            */
            
            /* Brokerage Account (string) */
            String brokerage_acnt = (String)rqstDatas.Fget(BROKERAGE_ACNT);
            br_account_id = Long.parseLong(brokerage_acnt);
            
            /* Stock Symbol (string) */
            symbol = (String)rqstDatas.Fget(SYMBOL);
            
            /* Quantity of Stock (long) */
            Integer squantity = (Integer)rqstDatas.Fget(QUANTITY);

            newquantity = new Long(squantity);
            if (newquantity.longValue() < 1) {
                rqstDatas.Fchg(STATUS, "Invalid Stock Quantity");
                error = new String("Invalid Stock Quantity");
                throw new TuxATMITPException(0, error);
            }
            
            /* Price per share (float) */
            newprice = (Float)rqstDatas.Fget(PRICE);
            if (newprice.floatValue() <= 0.0) {
                rqstDatas.Fchg(STATUS, "Invalid Stock Price");
                error = new String("Invalid Stock Price");
                throw new TuxATMITPException(0, error);
            }
            
            Float tt = new Float(newquantity * newprice);
            
            amts = tt.toString();
            
            
            /* 
             * setup connection to DB 
             */
            
            connDB = myAppCtxt.getConnection();
            stmtDB = connDB.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            
            /*
            * Get bank account corresponding to brokerage account
            */

            stmtSQL = "SELECT ACCOUNT_ID from BRACCOUNT where BR_ACCOUNT_ID = " + br_account_id;
            rs = stmtDB.executeQuery(stmtSQL);
            
            while (rs.next()) {
                account_id = rs.getLong(1);
                break;
            }       
            rs.close();     
            
            /*
             * Assume we have sufficient funds in Account
             */
            
            stmtSQL = "SELECT SYMBOL from BRHOLDING where BR_ACCOUNT_ID = " + br_account_id + " AND SYMBOL = '" + symbol + "'";
            rs = stmtDB.executeQuery(stmtSQL);
            
            insert = true;
            while (rs.next()) {
                insert = false;
                symbol = rs.getString(1);
                break;
            }
            rs.close();
            
            if (insert) {
                /*
                * First Stock of This Type
                */
                
                quantity = newquantity;
                avg_price = newprice;
                
                stmtSQL = "INSERT into BRHOLDING (BR_ACCOUNT_ID, SYMBOL, QUANTITY, AVG_PRICE) VALUES (" +
                            br_account_id + ", '" + symbol + "', " + quantity + ", " + avg_price +")";
                int rec = stmtDB.executeUpdate(stmtSQL);
                if (rec == 0) {     /* Failure to insert */
                    rqstDatas.Fchg(STATUS, "Cannot update BRHOLDING");
                    error = new String("Cannot update BRHOLDING");
                    throw new TuxATMITPException(0, error);
                }
            } else {
                /*
                 * Update existing record of this stock
                 */
                
                stmtSQL = "SELECT QUANTITY, AVG_PRICE from BRHOLDING where BR_ACCOUNT_ID = " + br_account_id + " AND SYMBOL = '" + symbol + "'";
                rs = stmtDB.executeQuery(stmtSQL);
                
                while (rs.next()) {
                    quantity = rs.getLong(1);
                    avg_price = rs.getFloat(2);
                    break;
                }
                
                avg_price = (((quantity * avg_price) + (newquantity * newprice)) / (quantity + newquantity));
                quantity = quantity + newquantity;
                
                rs.updateLong(1, quantity);
                rs.updateFloat(2, avg_price);
                rs.updateRow();
                rs.close();
                
            }
        
            /*
            * Withdraw funds from Account
            */
            
            /* make withdraw request FML32 buffer */
                       
            reqfb = new TypedFML32();
            
            /* put ID and amount in request buffer */
            Integer acc = new Integer(account_id.intValue());
            reqfb.Fchg(ACCOUNT_ID  , acc);
            reqfb.Fchg(SAMOUNT , amts);

            myTuxReply = myAppCtxt.tpcall("WITHDRAWAL", reqfb, TPSIGRSTRT);
            
            reqfb = (TypedFML32)myTuxReply.getReplyBuffer();
            
            db_amts = (String) reqfb.Fget(SBALANCE);

            String tmp = db_amts.substring(1);
            db_bal = new Float(tmp);
            
            if (tmp == null || db_bal < 0.0) {
                rqstDatas.Fchg(STATUS, "illegal withdrawl account balance");
                error = new String("illegal withdrawl account balance");
                throw new TuxATMITPException(0, error);
            }
            
            /* Insert history record into DB */

            volume = newquantity;
            new_price = newprice;
            
            stmtSQL = "INSERT into BRHISTORY (BR_ACCOUNT_ID, SYMBOL, TRANSACTION, AVG_PRICE, QUANTITY) VALUES (" +
                    br_account_id + ", '" + symbol + "', '" +transaction + "', " + new_price + ", " + volume +")";
            
            int rec = stmtDB.executeUpdate(stmtSQL);
            if (rec == 0) {     /* Failure to insert */
                rqstDatas.Fchg(STATUS, "Cannot update BRHISTORY");
                error = new String("Cannot update BRHISTORY");
                throw new TuxATMITPException(0, error);
            }
            
            /* post message */
                        
            String post_msg = String.format("Account %1$d bought %2$d %3$s @ %4$6.2f", br_account_id, newquantity, symbol, newprice);

            boolean ret = post_event("BROKER_TRANSACTION", post_msg);
            if (ret == false) {
                rqstDatas.Fchg(STATUS, "Post message failed");
                throw new TuxATMITPException(0, "Post message failed");
            }
            
            
            /* 
             * Prepare buffer for successful return.
             * Re-use the request buffer 'rqstDatas'.
             */

            rqstDatas.Fchg(PRICE, avg_price);
            
            Integer tq = new Integer(quantity.intValue());
            rqstDatas.Fchg(QUANTITY, tq);
            
            /* commit transaction if needed */
            if (1 == trnStrtInSVC) { 
                myAppCtxt.userlog("JAVA-INFO: tpcommit current transaction...");
                trnRtn = myAppCtxt.tpcommit(0);
                myAppCtxt.userlog("JAVA-INFO: tpcommit return " + trnRtn);
            }

            myAppCtxt.tpreturn(TPSUCCESS, 0, rqstDatas, 0);
 
        } catch (SQLException e) {
            String errMsg = "JAVA-ERROR: SQLException: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            error = new String("SQL Operation failed");
            failed = true;            
        }
        catch (Ferror e) {
            String errMsg = "JAVA-ERROR: Ferror: (" + e.getMessage() + ")";
            myAppCtxt.userlog(errMsg);
            error = new String("FML error");
            failed = true;
        }
        catch (TuxATMIRMException e) {
            String errMsg = "TuxATMIRMException: (" + e.getMessage() + ").";
            myAppCtxt.userlog("JAVA-ERROR: %s",  errMsg);
            error = new String(e.getMessage());
            failed = true;
            throw new TuxException(errMsg);
        } catch (TuxATMITPException e) {
            String errMsg = null;
            if (e.getMessage() == null) {
                errMsg = new String("Cannot withdraw from bank account");
            } else {
                errMsg = e.getMessage();
            }
            myAppCtxt.userlog("JAVA-ERROR: TuxATMITPException: (%s).", errMsg);
            error = new String(errMsg);
            failed = true;
        } catch (Exception e) {
            String errMsg = "ERROR: Exception: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            error = new String(e.getMessage());
            failed = true;
            throw new TuxException(errMsg);
        } catch (Throwable e) {
            String errMsg = "ERROR: Throwable: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            error = new String(e.getMessage());
            failed = true;
            throw new TuxException(errMsg);
        } finally {
            if (null != stmtDB)
                try {
			stmtDB.close();
                    /* TODO: 
                     * <SUB 20> use Statement.close() to close connection to DB.
                     */
                } catch (SQLException e) {}
            
            /* abort transaction if needed */
            try {
                if (1 == trnStrtInSVC) {
                    if (failed) {
                        myAppCtxt.userlog("JAVA-INFO: tpabort current transaction...");
                        trnRtn = myAppCtxt.tpabort(0);
                        myAppCtxt.userlog("JAVA-INFO: tpabort return " + trnRtn);
                    }
                    trnStrtInSVC = 0;
                }
            } catch (TuxATMITPException e) {
                myAppCtxt.userlog("JAVA-ERROR: TuxATMITPException: (%s).", e.getMessage());
                error = new String(e.getMessage());
                failed = true;
            }
            
            if (failed) {
                try {
                    rqstDatas.Fchg(STATUS, error);
                } catch (Ferror e) {
                    // Auto-generated catch block
                    e.printStackTrace();
                }
                myAppCtxt.tpreturn(TPFAIL, 0, rqstDatas, 0);
 
            }
        }

        
    }


    public void SellStock(TPSVCINFO rqst) throws TuxException, TuxATMITPException {
        TypedFML32      rqstDatas;
        TypedFML32      reqfb;
        Connection      connDB = null;
        Statement       stmtDB = null;
        String          stmtSQL;
        ResultSet       rs;
        TuxATMIReply    myTuxReply;
        String          transaction = null;
        String          error = null;
        boolean         failed = false;
        boolean         insert;
        int             trnLvl, trnStrtInSVC = 0, trnRtn;
        long            trnFlags = 0;
        
        Long      br_account_id;
        String    symbol = null;
        Long      quantity = null;
        Long      account_id = null;
        Long      volume = null;
        Float     avg_price = null;
        Float     new_price = null;
        String    amts = null;
        String    db_amts = null;
        Float     db_bal = null;
        Long      newquantity = null;
        Float     newprice = null;
        
        

        myAppCtxt = getTuxAppContext();
        
        myAppCtxt.userlog("JAVA-INFO: Entering TJS_BROKER.SellStock().");
        
        // Get user data
        rqstDatas = (TypedFML32)rqst.getServiceData();
        
        try{
            /* Setup global transaction if needed */
            trnStrtInSVC = 0;
            trnLvl = myAppCtxt.tpgetlev();
            if (0 == trnLvl) {
                long trnTime = 6000;
                myAppCtxt.userlog("JAVA-INFO: Start a transaction...");
                trnRtn = myAppCtxt.tpbegin(trnTime, trnFlags);
                myAppCtxt.userlog("JAVA-INFO: tpbegin return " + trnRtn);
                trnStrtInSVC = 1;
            }
            
            rqstDatas.Fchg(STATUS, "Shares Sold");
      
            transaction = "SELL";
        

            /*
            * Get all values for service request from fielded buffer
            */
            
            /* Brokerage Account (string) */
            
            String brokerage_acnt = (String)rqstDatas.Fget(BROKERAGE_ACNT);
            br_account_id = Long.parseLong(brokerage_acnt);
            
            /* Stock Symbol (string) */
            
            symbol = (String)rqstDatas.Fget(SYMBOL);    
            
            /* Quantity of Stock (long) */

            Integer squantity = (Integer)rqstDatas.Fget(QUANTITY);
            newquantity = new Long(squantity);
            if (newquantity.longValue() < 1) {
                rqstDatas.Fchg(STATUS, "Invalid Stock Quantity");
                error = new String("Invalid Stock Quantity");
                throw new TuxATMITPException(0, error);
            }
            
            /* Price per share (float) */

            newprice = (Float)rqstDatas.Fget(PRICE);
            if (newprice.floatValue() <= 0.0) {
                rqstDatas.Fchg(STATUS, "Invalid Stock Price");
                error = new String("Invalid Stock Price");
                throw new TuxATMITPException(0, error);
            }
            
            Float tt = new Float(newquantity * newprice);
            amts = tt.toString();
            
            
            /* 
             * setup connection to DB 
             */
            
            connDB = myAppCtxt.getConnection();
            stmtDB = connDB.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            
            /*
            * Get bank account corresponding to brokerage account
            */

            stmtSQL = "SELECT ACCOUNT_ID from BRACCOUNT where BR_ACCOUNT_ID = " + br_account_id;
            rs = stmtDB.executeQuery(stmtSQL);
            
            while (rs.next()) {
                account_id = rs.getLong(1);
                break;
            }
            
            rs.close();
            
            
            /*
             * Get Stock to sell
             */
            
            stmtSQL = "SELECT QUANTITY, AVG_PRICE from BRHOLDING where BR_ACCOUNT_ID = " + br_account_id + " AND SYMBOL = '" + symbol + "'";
            rs = stmtDB.executeQuery(stmtSQL);
            
            while (rs.next()) {
                quantity = rs.getLong(1);
                avg_price = rs.getFloat(2);
                break;
            }
            
            if (newquantity > quantity) {
                rqstDatas.Fchg(STATUS, "Not enough Stock to sell");
                throw new TuxATMITPException(0, "Not enough Stock to sell");
            }
            
                        
            avg_price = (((quantity * avg_price) - (newquantity * newprice)) / (quantity - newquantity));
            quantity = quantity - newquantity;
                
            rs.updateLong(1, quantity);
            rs.updateFloat(2, avg_price);
            rs.updateRow();
            rs.close();
       
        
            /*
            * Deposit funds to Account
            */
            
            /* make deposit request buffer */
                       
            reqfb = new TypedFML32();
            
            /* put ID in request buffer */
            Integer acc = new Integer(account_id.intValue());
            reqfb.Fchg(ACCOUNT_ID, acc);
            /* put amount in request buffer */
            reqfb.Fchg(SAMOUNT, amts);

            myTuxReply = myAppCtxt.tpcall("DEPOSIT", reqfb, TPSIGRSTRT);
            
            
            /* Insert history record */

            volume = newquantity;
            new_price = newprice;
            
            stmtSQL = "INSERT into BRHISTORY (BR_ACCOUNT_ID, SYMBOL, TRANSACTION, AVG_PRICE, QUANTITY) VALUES (" +
                    br_account_id + ", '" + symbol + "', '" +transaction + "', " + new_price + ", " + volume +")";
            
            int rec = stmtDB.executeUpdate(stmtSQL);
            if (rec == 0) {     /* Failure to insert */
                rqstDatas.Fchg(STATUS, "Cannot update BRHISTORY");
                error = new String("Cannot update BRHISTORY");
                throw new TuxATMITPException(0, error);
            }
            
            /* post message */
                        
            String post_msg = String.format("Account %1$d Sold %2$d %3$s @ %4$6.2f", br_account_id, newquantity, symbol, newprice);

            boolean ret = post_event("BROKER_TRANSACTION", post_msg);
            if (ret == false) {
                rqstDatas.Fchg(STATUS, "Post message failed");
                throw new TuxATMITPException(0, "Post message failed");
            }
            
            
            /* prepare buffer for successful return */

            Integer tq = new Integer(quantity.intValue());
            rqstDatas.Fchg(QUANTITY, tq);

            myAppCtxt.tpreturn(TPSUCCESS, 0, rqstDatas, 0);
 
        } catch (SQLException e) {
            String errMsg = "JAVA-ERROR: SQLException: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            error = new String("SQL Operation failed");
            failed = true;            
        }
        catch (Ferror e) {
            String errMsg = "JAVA-ERROR: Ferror: (" + e.getMessage() + ")";
            myAppCtxt.userlog(errMsg);
            error = new String("FML error");
            failed = true;
        }
        catch (TuxATMIRMException e) {
            String errMsg = "TuxATMIRMException: (" + e.getMessage() + ").";
            myAppCtxt.userlog("JAVA-ERROR: %s", errMsg);
            throw new TuxException(errMsg);
        } catch (TuxATMITPException e) {
            String errMsg = null;
            if (e.getMessage() == null) {
                errMsg = new String("Cannot deposit to bank account");
            } else {
                errMsg = e.getMessage();
            }
            myAppCtxt.userlog("JAVA-ERROR: TuxATMITPException: (%s).", errMsg);
            error = new String(errMsg);
            failed = true;
        } catch (Exception e) {
            String errMsg = "ERROR: Exception: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            throw new TuxException(errMsg);
        } catch (Throwable e) {
            String errMsg = "ERROR: Throwable: (" + e.getMessage() + ").";
            myAppCtxt.userlog(errMsg);
            throw new TuxException(errMsg);
        } finally {
            if (null != stmtDB)
                try {
                    stmtDB.close();
                } catch (SQLException e) {}
            
            if (failed) {
                try {
                    rqstDatas.Fchg(STATUS, error);
                } catch (Ferror e) {
                    // Auto-generated catch block
                    e.printStackTrace();
                }
                myAppCtxt.tpreturn(TPFAIL, 0, rqstDatas, 0);
            }
        }
    }
    
    private boolean post_event (String event, String msg) throws TuxATMITPException, TuxException {
        TypedFML32    reqfb = null;
        String        timenow = null;
        
        try {
            reqfb = new TypedFML32();
            reqfb.Fchg(EVENT_NAME, event);
            
            SimpleDateFormat fmt = new SimpleDateFormat("EEE MMM dd HH:mm:ss yyyy");
            timenow = fmt.format(new Date());
            
            reqfb.Fchg(EVENT_TIME, timenow);
            reqfb.Fchg(STATUS, msg);
            
            myAppCtxt.tpcall("POST_EVENT", reqfb, TPSIGRSTRT);
            
            return true;
            
        } catch (Ferror e) {
            return false;
        } catch (TuxATMITPException e) {
            String errMsg = null;
            if (e.getMessage() == null) {
                errMsg = new String("post message failed");
            } else {
                errMsg = e.getMessage();
            }

            myAppCtxt.userlog("WARN: Cannot Post Event %s: %s. Error: %s", event, msg, errMsg);
            return false;
        } 
    }

}
