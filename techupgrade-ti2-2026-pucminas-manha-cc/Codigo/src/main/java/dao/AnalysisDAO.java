package dao;

import db.ConnectionFactory;
import dto.ComponentResponse;
import model.Component;
import model.DetectedComponent;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AnalysisDAO {
    public String createAnalysis(Long userId, String purpose, String inputMethod, String status, String summary, String rawText) throws Exception {
        String sql = "INSERT INTO analyses (user_id, purpose_id, input_method, processing_status, summary, raw_ocr_text) " +
                "VALUES (?, (SELECT id FROM purposes WHERE name = ?), ?, ?, ?, ?) RETURNING id";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            if (userId == null) st.setObject(1, null); else st.setLong(1, userId);
            st.setString(2, purpose);
            st.setString(3, inputMethod);
            st.setString(4, status);
            st.setString(5, summary);
            st.setString(6, rawText);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return rs.getString("id");
            }
        }
        return UUID.randomUUID().toString();
    }

    public String addAnalysisComponent(String analysisId, DetectedComponent detected, String status, String message) throws Exception {
        String sql = "INSERT INTO analysis_components (analysis_id, component_type_id, matched_component_id, component_name, current_spec, status, message) " +
                "VALUES (?::uuid, (SELECT id FROM component_types WHERE name = ?), ?, ?, ?, ?, ?) RETURNING id";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, analysisId);
            st.setString(2, detected.getType());
            if (detected.getMatchedComponent() == null) st.setObject(3, null); else st.setLong(3, detected.getMatchedComponent().getId());
            st.setString(4, detected.getType());
            st.setString(5, detected.getValue());
            st.setString(6, status);
            st.setString(7, message);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return rs.getString("id");
            }
        }
        return null;
    }

    public void addRecommendation(String analysisId, String analysisComponentId, Component recommended, String text, String compatibilityNote, Component current) throws Exception {
        String sql = "INSERT INTO recommendation_items " +
                "(analysis_id, analysis_component_id, recommended_component_id, component_type_id, recommendation_text, compatibility_note, current_benchmark_score, recommended_benchmark_score, benchmark_gain, estimated_price) " +
                "VALUES (?::uuid, ?::uuid, ?, (SELECT id FROM component_types WHERE name = ?), ?, ?, ?, ?, ?, ?)";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, analysisId);
            st.setString(2, analysisComponentId);
            st.setLong(3, recommended.getId());
            st.setString(4, recommended.getType());
            st.setString(5, text);
            st.setString(6, compatibilityNote);
            st.setBigDecimal(7, current == null ? null : current.getBenchmarkScore());
            st.setBigDecimal(8, recommended.getBenchmarkScore());
            if (current != null && current.getBenchmarkScore() != null && recommended.getBenchmarkScore() != null) {
                st.setBigDecimal(9, recommended.getBenchmarkScore().subtract(current.getBenchmarkScore()));
            } else {
                st.setBigDecimal(9, null);
            }
            st.setBigDecimal(10, recommended.getPrice());
            st.executeUpdate();
        }
    }

    public List<String> historyByUser(long userId) throws Exception {
        List<String> ids = new ArrayList<>();
        String sql = "SELECT id FROM analyses WHERE user_id = ? ORDER BY created_at DESC LIMIT 30";
        try (Connection connection = ConnectionFactory.getConnection();
             PreparedStatement st = connection.prepareStatement(sql)) {
            st.setLong(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) ids.add(rs.getString("id"));
            }
        }
        return ids;
    }
}
