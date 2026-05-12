package service;

import static spark.Spark.*;

import com.google.gson.Gson;

import dao.UserDAO;
import dto.AuthRequest;
import dto.ApiResponse;
import model.User;
import spark.Request;
import spark.Response;

public class UserService {

    private final UserDAO userDAO;
    private final Gson gson;

    public UserService() {
        userDAO = new UserDAO();
        gson = new Gson();
    }

    /*public Object register(Request req, Response res) {
        try {

            AuthRequest request = gson.fromJson(req.body(), AuthRequest.class);

            boolean created = userDAO.create(
                request.getNome(),
                request.getEmail(),
                request.getPassword()
            );

            res.type("application/json");

            if(created) {
                return gson.toJson(new ApiResponse(true, "Usuário criado com sucesso"));
            }

            res.status(400);
            return gson.toJson(new ApiResponse(false, "Erro ao criar usuário"));

        } catch (Exception e) {
            res.status(500);
            return gson.toJson(new ApiResponse(false, e.getMessage()));
        }
    }*/

    public Object getById(Request req, Response res) {
        try {

            long id = Long.parseLong(req.params(":id"));

            User user = userDAO.findById(id);

            res.type("application/json");

            if(user != null) {
                return gson.toJson(user);
            }

            res.status(404);
            return gson.toJson(new ApiResponse(false, "Usuário não encontrado"));

        } catch (Exception e) {
            res.status(500);
            return gson.toJson(new ApiResponse(false, e.getMessage()));
        }
    }
}