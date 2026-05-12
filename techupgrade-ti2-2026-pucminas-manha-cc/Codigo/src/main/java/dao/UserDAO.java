package dao;

import model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class UserDAO extends DAO {
    public UserDAO() {
        super();
    }

    public User create(String nome, String email, String passwordHash) throws Exception {
        String sql = "INSERT INTO users (full_name, email, password_hash) VALUES (?, ?, ?) RETURNING id, full_name, email, password_hash, role, created_at";
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, nome);
            st.setString(2, email.toLowerCase());
            st.setString(3, passwordHash);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public User findByEmail(String email) throws Exception {
        String sql = "SELECT id, full_name, email, password_hash, role, created_at FROM users WHERE lower(email) = lower(?) AND is_active = true";
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public User findById(long id) throws Exception {
        String sql = "SELECT id, full_name, email, password_hash, role, created_at FROM users WHERE id = ? AND is_active = true";
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setLong(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public void updateLastLogin(long id) throws Exception {
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement("UPDATE users SET last_login_at = NOW() WHERE id = ?")) {
            st.setLong(1, id);
            st.executeUpdate();
        }
    }

    public void updateProfile(long id, String nome, String email) throws Exception {
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement("UPDATE users SET full_name = ?, email = ?, updated_at = NOW() WHERE id = ?")) {
            st.setString(1, nome);
            st.setString(2, email.toLowerCase());
            st.setLong(3, id);
            st.executeUpdate();
        }
    }

    public void updatePassword(long id, String hash) throws Exception {
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement("UPDATE users SET password_hash = ?, updated_at = NOW() WHERE id = ?")) {
            st.setString(1, hash);
            st.setLong(2, id);
            st.executeUpdate();
        }
    }

    public void deactivate(long id) throws Exception {
        try (Connection connection = getConnection();
             PreparedStatement st = connection.prepareStatement("UPDATE users SET is_active = false, updated_at = NOW() WHERE id = ?")) {
            st.setLong(1, id);
            st.executeUpdate();
        }
    }

    private User map(ResultSet rs) throws Exception {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setNome(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getString("created_at"));
        return user;
    }
}
