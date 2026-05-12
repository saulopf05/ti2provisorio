package config;
import io.github.cdimascio.dotenv.Dotenv;

public class ServerConfig {
    private final int port;
    private final String dbUrl;
    private final String dbUser;
    private final String dbPassword;
    private final String mistralApiKey;
    private final String jwtSecret;
    private final String corsOrigin;
    private final Dotenv dotenv;
    
    public ServerConfig() {
        System.out.println("Configurando e lendo variáveis de ambiente");
        this.dotenv = Dotenv.configure()
                    .ignoreIfMissing()
                    .load();
                    
        this.port = Integer.parseInt(dotenv.get("PORT", "8080"));

        this.dbUrl             = dotenv.get("DB_URL");
        this.dbUser            = dotenv.get("DB_USER");
        this.dbPassword        = dotenv.get("DB_PASSWORD");
        this.mistralApiKey     = dotenv.get("MISTRAL_API_KEY");
        this.jwtSecret         = dotenv.get("JWT_SECRET");
        this.corsOrigin        = dotenv.get("CORS_ORIGIN");


        System.out.println(dbUrl);
        System.out.println(dbUser);

    }

    public int getPort() { return port; }
    public String getMistralApiKey() { return mistralApiKey; }
    public String getJwtSecret() { return jwtSecret; }
    public String getCorsOrigin() { return corsOrigin; }
    public String getUrl() { return this.dbUrl; }
    public String getUser() { return this.dbUser; }
    public String getPassword() { return this.dbPassword; }
}
