package service;

import com.google.gson.Gson;

import dao.ComponentDAO;
import spark.Request;
import spark.Response;

public class ComponentService {

    private final ComponentDAO componentDAO;
    private final Gson gson;

    public ComponentService() {
        componentDAO = new ComponentDAO();
        gson = new Gson();
    }

    public Object getAll(Request req, Response res) {
        try {

            res.type("application/json");

            return gson.toJson(componentDAO.findAllActive());

        } catch (Exception e) {
            res.status(500);
            return gson.toJson(e.getMessage());
        }
    }

    public Object getByType(Request req, Response res) {
        try {

            String type = req.params(":type");

            res.type("application/json");

            return gson.toJson(componentDAO.findByType(type));

        } catch (Exception e) {
            res.status(500);
            return gson.toJson(e.getMessage());
        }
    }
}