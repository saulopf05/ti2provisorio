package service;

import com.google.gson.Gson;

import dao.AnalysisDAO;
import dto.ApiResponse;
import spark.Request;
import spark.Response;

public class AnalysisService {

    private final AnalysisDAO analysisDAO;
    private final Gson gson;

    public AnalysisService() {
        analysisDAO = new AnalysisDAO();
        gson = new Gson();
    }

    public Object history(Request req, Response res) {
        try {

            long userId = Long.parseLong(req.params(":userId"));

            res.type("application/json");

            return gson.toJson(analysisDAO.historyByUser(userId));

        } catch (Exception e) {
            res.status(500);
            return gson.toJson(new ApiResponse(false, e.getMessage()));
        }
    }
}