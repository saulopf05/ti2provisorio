package dao;

import db.ConnectionFactory;
import model.Component;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ComponentDAO {
    public List<Component> findAllActive() throws Exception {
        String sql = baseSql() + " ORDER BY ct.name, c.benchmark_score NULLS LAST, c.model";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<Component> findByType(String type) throws Exception {
        String sql = baseSql() + " WHERE ct.name = ? AND c.is_active = true ORDER BY c.benchmark_score DESC NULLS LAST";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, type.toUpperCase());
            try (ResultSet rs = st.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public Component findBestTextMatch(String type, String text) throws Exception {
        if (text == null || text.trim().isEmpty()) return null;
        String normalized = normalize(text);
        List<Component> all = findByType(type);
        Component best = null;
        int bestScore = 0;
        for (Component c : all) {
            int score = score(normalized, normalize(c.getBrand() + " " + c.getModel()));
            if (score > bestScore) {
                bestScore = score;
                best = c;
            }
        }
        return bestScore >= 55 ? best : null;
    }

    public List<Component> findUpgradeCandidates(Component current, String purpose, String socket, String ramType, Integer psuWatts, int limit) throws Exception {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.*, ct.name AS type_name, COALESCE(best.price, c.msrp_price) AS effective_price, best.product_url ");
        sql.append("FROM components_catalog c ");
        sql.append("JOIN component_types ct ON ct.id = c.component_type_id ");
        sql.append("JOIN purposes p ON p.name = ? ");
        sql.append("JOIN purpose_component_weights pcw ON pcw.purpose_id = p.id AND pcw.component_type_id = c.component_type_id ");
        sql.append("LEFT JOIN LATERAL (SELECT price, product_url FROM component_offers o WHERE o.component_id = c.id AND o.in_stock = true ORDER BY price ASC LIMIT 1) best ON true ");
        sql.append("WHERE c.is_active = true AND ct.name = ? ");
        sql.append("AND c.benchmark_score IS NOT NULL AND c.benchmark_score > ? ");
        sql.append("AND COALESCE(best.price, c.msrp_price) IS NOT NULL AND COALESCE(best.price, c.msrp_price) > 0 ");

        if ("CPU".equalsIgnoreCase(current.getType()) && socket != null) {
            sql.append("AND c.socket = ? ");
        }
        if ("RAM".equalsIgnoreCase(current.getType()) && ramType != null) {
            sql.append("AND c.ram_type = ? ");
        }
        if ("GPU".equalsIgnoreCase(current.getType()) && psuWatts != null) {
            sql.append("AND (c.tdp_watts IS NULL OR (c.tdp_watts + ?) <= ?) ");
        }

        sql.append("ORDER BY ((c.benchmark_score - ?) * pcw.weight) / COALESCE(best.price, c.msrp_price) DESC LIMIT ?");

        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql.toString())) {
            int i = 1;
            st.setString(i++, purpose);
            st.setString(i++, current.getType());
            st.setBigDecimal(i++, safeBenchmark(current));
            if ("CPU".equalsIgnoreCase(current.getType()) && socket != null) st.setString(i++, socket);
            if ("RAM".equalsIgnoreCase(current.getType()) && ramType != null) st.setString(i++, ramType);
            if ("GPU".equalsIgnoreCase(current.getType()) && psuWatts != null) {
                int cpuTdp = 125;
                st.setInt(i++, cpuTdp + 150);
                st.setInt(i++, psuWatts);
            }
            st.setBigDecimal(i++, safeBenchmark(current));
            st.setInt(i, limit);
            try (ResultSet rs = st.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public Component findPsuForWatts(int requiredWatts) throws Exception {
        String sql = baseSql() + " WHERE ct.name = 'PSU' AND c.wattage >= ? AND c.is_active = true ORDER BY c.wattage ASC, effective_price ASC LIMIT 1";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, requiredWatts);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    private String baseSql() {
        return "SELECT c.*, ct.name AS type_name, COALESCE(best.price, c.msrp_price) AS effective_price, best.product_url " +
                "FROM components_catalog c " +
                "JOIN component_types ct ON ct.id = c.component_type_id " +
                "LEFT JOIN LATERAL (SELECT price, product_url FROM component_offers o WHERE o.component_id = c.id AND o.in_stock = true ORDER BY price ASC LIMIT 1) best ON true ";
    }

    private List<Component> mapList(ResultSet rs) throws Exception {
        List<Component> list = new ArrayList<>();
        while (rs.next()) list.add(map(rs));
        return list;
    }

    private Component map(ResultSet rs) throws Exception {
        Component c = new Component();
        c.setId(rs.getLong("id"));
        c.setType(rs.getString("type_name"));
        c.setBrand(rs.getString("brand"));
        c.setModel(rs.getString("model"));
        c.setSocket(rs.getString("socket"));
        c.setRamType(rs.getString("ram_type"));
        c.setCapacityGb(rs.getBigDecimal("capacity_gb"));
        c.setVramGb(rs.getBigDecimal("vram_gb"));
        int tdp = rs.getInt("tdp_watts");
        c.setTdpWatts(rs.wasNull() ? null : tdp);
        c.setBenchmarkScore(rs.getBigDecimal("benchmark_score"));
        c.setPrice(rs.getBigDecimal("effective_price"));
        int wattage = rs.getInt("wattage");
        c.setWattage(rs.wasNull() ? null : wattage);
        c.setInterfaceType(rs.getString("interface_type"));
        c.setUrl(rs.getString("product_url"));
        return c;
    }

    private BigDecimal safeBenchmark(Component c) {
        return c.getBenchmarkScore() == null ? BigDecimal.ZERO : c.getBenchmarkScore();
    }

    private String normalize(String value) {
        return value == null ? "" : value.toLowerCase().replaceAll("[^a-z0-9]+", "");
    }

    private int score(String a, String b) {
        if (a.contains(b) || b.contains(a)) return 100;
        int common = 0;
        for (int i = 0; i < b.length(); i++) {
            if (a.indexOf(b.charAt(i)) >= 0) common++;
        }
        return b.length() == 0 ? 0 : (common * 100 / b.length());
    }
}
