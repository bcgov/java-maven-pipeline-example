package com.example;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebListener
public class DeploymentTimestampListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        sce.getServletContext().setAttribute("deploymentTimestamp", timestamp);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No need to handle
    }
}
