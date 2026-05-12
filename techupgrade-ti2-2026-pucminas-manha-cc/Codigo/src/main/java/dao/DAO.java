package dao;

import java.sql.*;
import config.ServerConfig;
public class DAO {
    private final ServerConfig config;

    public DAO() {
        this.config = new ServerConfig();
    }
    
    public Connection getConnection() throws SQLException {

        return DriverManager.getConnection(
            config.getUrl(), config.getUser(), config.getPassword()
        );
    }
}
