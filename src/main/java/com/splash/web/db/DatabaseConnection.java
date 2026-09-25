package com.splash.web.db;

import java.lang.reflect.InvocationTargetException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/lava_rapido";
    private static final String USER = "app_lava";
    private static final String PASS = "753159jKl&";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").getDeclaredConstructor().newInstance();
        } catch (ClassNotFoundException | NoSuchMethodException e) {
            throw new SQLException(e);
        } catch (InvocationTargetException | InstantiationException | IllegalAccessException e) {
            throw new RuntimeException(e);
        }

        try {
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

}
