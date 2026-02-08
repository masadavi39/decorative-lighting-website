package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for obtaining database connections. This project uses a
 * MySQL database named {@code light_csdl} with the default root user and
 * password defined by the user. If you need to adjust credentials or
 * connection settings, modify the constants below.
 */
public class DBConnection {
private static final String URL ="jdbc:mysql://localhost:3386/light_csdl?useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&connectionCollation=utf8mb4_unicode_ci&serverTimezone=UTC&useSSL=false";
    private static final String USER = "root";
    private static final String PASS = "";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    /**
     * Gets a new {@link Connection} to the database. The JDBC driver will be
     * loaded once per JVM via {@code Class.forName}.
     *
     * @return an active connection
     * @throws SQLException if the driver cannot be loaded or the connection
     *                      cannot be established
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Unable to load JDBC driver", e);
        }
    }
}