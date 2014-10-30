package todd;
import com.oracle.tuxedo.tjatmi.TuxATMITPException;
import com.oracle.tuxedo.tjatmi.TuxAppContext;
import com.oracle.tuxedo.tjatmi.TuxAppContextUtil;
public class TuxedoThreads {
    public static final ThreadLocal<TuxAppContext> userThreadLocal = new ThreadLocal<TuxAppContext>();
    public static void set(TuxAppContext tc) {
        userThreadLocal.set(tc);
    }
    public static TuxAppContext get() throws TuxATMITPException {
        TuxAppContext tc = userThreadLocal.get();
        if (null == tc) {
            // No Tuxedo context gotten for this thread yet, so get one
            TuxAppContextUtil.tpappthrinit(null);
            tc = TuxAppContextUtil.getTuxAppContext();
            userThreadLocal.set(tc);
        }
        return userThreadLocal.get();
    }
} 
