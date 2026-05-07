package app;

import static spark.Spark.*;

import config.ServerConfig;
import service.AnalysisService;
import service.ComponentService;
import service.UserService;

public class Aplicacao {

    public static void main(String[] args) {

        // Carrega configurações do sistema
        ServerConfig config = new ServerConfig();

        // Define porta do servidor
        port(config.getPort());

        // Configuração de CORS
        before((request, response) -> {

            response.header(
                "Access-Control-Allow-Origin",
                config.getCorsOrigin()
            );

            response.header(
                "Access-Control-Allow-Methods",
                "GET,POST,PUT,DELETE,OPTIONS"
            );

            response.header(
                "Access-Control-Allow-Headers",
                "Content-Type,Authorization"
            );

            response.type("application/json");
        });

        // Responde requisições OPTIONS
        options("/*", (request, response) -> {
            return "OK";
        });

        // Inicializa services
        UserService userService = new UserService();
        ComponentService componentService = new ComponentService();
        AnalysisService analysisService = new AnalysisService();

        // Rota inicial
        get("/", (req, res) -> {
            return "{\"message\":\"TechUpgrade API ONLINE\"}";
        });

        // USERS
        post("/users/register", userService::register);

        get("/users/:id", userService::getById);

        // COMPONENTS
        get("/components", componentService::getAll);

        get("/components/type/:type", componentService::getByType);

        // ANALYSIS
        get("/analysis/history/:userId", analysisService::history);

        System.out.println("TechUpgrade API ONLINE");
        System.out.println("Porta: " + config.getPort());
    }
}