package app;

import static spark.Spark.*;

import config.ServerConfig;
import service.AnalysisService;
import controler.*;

public class Aplicacao {

    public static void main(String[] args) throws Exception{

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

        AnalysisService analysisService = new AnalysisService();

        // Rota inicial
        get("/", (req, res) -> {
            return "{\"message\":\"TechUpgrade API ONLINE\"}";
        });

        //UserRoutes
        UserController.startUserRoutes();
        ComponentController.startComponentRoutes();



        // ANALYSIS
        get("/analysis/history/:userId", analysisService::history);
        

        System.out.println("TechUpgrade API ONLINE");
        System.out.println("Porta: " + config.getPort());
    }
}