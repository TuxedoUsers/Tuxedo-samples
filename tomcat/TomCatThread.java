import org.apache.catalina.startup.*;
public class TomCatThread extends Thread {
    private Bootstrap bs = null;
    public void run() {
        try {
            bs = new Bootstrap();
            bs.setCatalinaHome("/home/oracle/projects/tc/apache-tomcat-7.0.54");
            bs.start();
            System.out.println("After starting Tomcat Thread.");
        } catch (Exception e) {
            System.out.println("Received exception" + e);
        }
    }
    public void shutdown() {
        try {
            bs.stop();
            bs.destroy();
        } catch (Exception e) {
            System.out.println("Received exception while shutting down Tomcat thread" + e);
        }
    }
}
