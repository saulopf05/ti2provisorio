package config;

public class ServerConfig {
    private final int port;
    private final String dbUrl;
    private final String dbUser;
    private final String dbPassword;
    private final String mistralApiKey;
    private final String jwtSecret;
    private final String corsOrigin;

    public ServerConfig() {
        this.port = readInt("PORT", 8080);
        this.dbUrl = read("DB_URL", "jdbc:postgresql://localhost:5432/techupgrade_db");
        this.dbUser = read("DB_USER", "postgres");
        this.dbPassword = read("DB_PASSWORD", "postgres");
        this.mistralApiKey = read("MISTRAL_API_KEY", "");
        this.jwtSecret = read("JWT_SECRET", "troque-este-segredo-em-producao");
        this.corsOrigin = read("CORS_ORIGIN", "*");

        System.setProperty("DB_URL", dbUrl);
        System.setProperty("DB_USER", dbUser);
        System.setProperty("DB_PASSWORD", dbPassword);
    }

    private String read(String name, String fallback) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) return fallback;
        return value.trim();
    }

    private int readInt(String name, int fallback) {
        try {
            return Integer.parseInt(read(name, String.valueOf(fallback)));
        } catch (Exception e) {
            return fallback;
        }
    }

    public int getPort() { return port; }
    public String getMistralApiKey() { return mistralApiKey; }
    public String getJwtSecret() { return jwtSecret; }
    public String getCorsOrigin() { return corsOrigin; }
}
