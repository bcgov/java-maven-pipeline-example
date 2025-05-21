<%@ page import="java.io.InputStream" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="javax.xml.xpath.XPath" %>
<%@ page import="javax.xml.xpath.XPathConstants" %>
<%@ page import="javax.xml.xpath.XPathFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="org.w3c.dom.Node" %>
<%
    String version = "N/A";
    try (InputStream input = getServletContext().getResourceAsStream("/META-INF/maven/bcgov.example/java-maven-pipeline-example/pom.xml")) {
        if (input != null) {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            Document doc = factory.newDocumentBuilder().parse(input);
            XPath xpath = XPathFactory.newInstance().newXPath();
            Node versionNode = (Node) xpath.evaluate("/project/version", doc, XPathConstants.NODE);
            if (versionNode != null) {
                version = versionNode.getTextContent();
            }
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
  <h2>Hello World! (andreas is cool)</h2>
<p>Version: <%= version %></p>
<p>Deployed at: <%= timestamp %></p>
<p>Java Runtime: <%= javaRuntimeVersion %></p>
<p>Tomcat Version: <%= tomcatVersion %></p>
</body>
</html>
