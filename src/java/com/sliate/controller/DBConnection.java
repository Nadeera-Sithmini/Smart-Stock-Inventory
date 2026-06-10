package com.sliate.controller;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() {
        Connection con = null;
        try {
            // MySQL Driver එක ලෝඩ් කරනවා
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Database එකට ලින්ක් වෙනවා (User: root | Pass: නැත)
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/inventory_management_system", "root", "");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }
}