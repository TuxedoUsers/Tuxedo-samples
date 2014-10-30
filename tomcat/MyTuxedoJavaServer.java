import com.oracle.tuxedo.tjatmi.TuxedoJavaServer;
import com.oracle.tuxedo.tjatmi.TuxException;
public class MyTuxedoJavaServer extends TuxedoJavaServer {
    private TomCatThread tc = null;
    public MyTuxedoJavaServer() {
        // Create the thread that will be used to bootstrap Tomcat
        tc = new TomCatThread();
        return;
    }
    public int tpsvrinit() throws TuxException {
        // Startup Tomcat
        tc.start();
        return 0;
    }
    public void tpsvrdone() {
        // Shutdown Tomcat
        tc.shutdown();
        return;
    }
}
