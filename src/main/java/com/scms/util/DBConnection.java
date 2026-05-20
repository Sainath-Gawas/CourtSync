package com.scms.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    
    // Exact path to your folder and file
    private static final String DB_URL = "jdbc:sqlite:C:/SCMS_Database/sports_club.db";

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Load the SQLite JDBC Driver
            Class.forName("org.sqlite.JDBC");
            // Open connection
            conn = DriverManager.getConnection(DB_URL);
            System.out.println("SUCCESS: Java has connected to the SQLite file!");
        } catch (Exception e) {
            System.out.println("FAILED: Connection error.");
            e.printStackTrace();
        }
        return conn;
    }
}