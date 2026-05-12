package controler;
import service.ComponentService;

import static spark.Spark.*;

public class ComponentController {
    public static void startComponentRoutes() throws Exception{
        
        ComponentService componentService = new ComponentService();
        System.out.println("Inicializando rotas de COMPONENTS");

        path("/api/v1/components", () -> {
            get("", componentService::getAll);
            get("/type/:type", componentService::getByType);
        });

    }
}
