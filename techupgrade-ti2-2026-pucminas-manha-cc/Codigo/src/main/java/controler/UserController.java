package controler;

import static spark.Spark.*;
import service.UserService;

public class UserController {

    public static void startUserRoutes() throws Exception{

        UserService userService = new UserService();
        System.out.println("Inicializando rotas de USUÁRIO");

        path("/api/v1/users", () -> {    
            //post("/register", userService::register);
            get("/:id", userService::getById);

        });

    }

}
