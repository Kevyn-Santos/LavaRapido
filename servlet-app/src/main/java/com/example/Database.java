package com.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

final class Database {

    private Database() {
    }

    static Connection getConnection() throws SQLException {
        String url = setting("DB_URL",
                "jdbc:mysql://localhost:3306/lava_rapido?useUnicode=true&characterEncoding=UTF-8&serverTimezone=America/Sao_Paulo");
        String user = setting("DB_USER", "root");
        String password = setting("DB_PASSWORD", "");
        return DriverManager.getConnection(url, user, password);
    }

    private static String setting(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null ? defaultValue : value;
    }
}
