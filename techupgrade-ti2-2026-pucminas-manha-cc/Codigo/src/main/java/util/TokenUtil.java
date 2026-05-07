package util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;

public class TokenUtil {
    private final String secret;

    public TokenUtil(String secret) {
        this.secret = secret;
    }

    public String generate(long userId, String email) {
        long exp = Instant.now().plusSeconds(60L * 60L * 24L * 7L).getEpochSecond();
        String payload = userId + ":" + email + ":" + exp;
        String payload64 = base64(payload);
        String signature = sign(payload64);
        return payload64 + "." + signature;
    }

    public Long validateAndGetUserId(String token) {
        try {
            if (token == null || !token.contains(".")) return null;
            String[] parts = token.split("\\.");
            if (parts.length != 2) return null;
            String expected = sign(parts[0]);
            if (!constantTimeEquals(expected, parts[1])) return null;
            String payload = new String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8);
            String[] values = payload.split(":", 3);
            if (values.length != 3) return null;
            long exp = Long.parseLong(values[2]);
            if (Instant.now().getEpochSecond() > exp) return null;
            return Long.parseLong(values[0]);
        } catch (Exception e) {
            return null;
        }
    }

    private String base64(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    private String sign(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) result |= a.charAt(i) ^ b.charAt(i);
        return result == 0;
    }
}
