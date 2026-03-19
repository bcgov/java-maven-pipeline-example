<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.Properties" %>
<%
    String version = "N/A";
    try (InputStream input = getServletContext().getResourceAsStream("/META-INF/maven/bcgov.example/java-maven-pipeline-example/pom.properties")) {
        if (input != null) {
            Properties props = new Properties();
            props.load(input);
            version = props.getProperty("version", "N/A");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    String timestamp = (String) application.getAttribute("deploymentTimestamp");
    String javaRuntimeVersion = System.getProperty("java.runtime.version");
    String tomcatVersion = application.getServerInfo();
%>
<html>
<body>
<h2>Hello World!</h2>
<p>Version: <%= version %></p>
<p>Deployed at: <%= timestamp %></p>
<p>Java Runtime: <%= javaRuntimeVersion %></p>
<p>Tomcat Version: <%= tomcatVersion %></p>
</body>
</html>