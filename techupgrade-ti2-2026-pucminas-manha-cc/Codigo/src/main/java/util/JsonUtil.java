package util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import spark.Response;

public class JsonUtil {
    private static final Gson GSON = new GsonBuilder().serializeNulls().create();

    public static String toJson(Object value) {
        return GSON.toJson(value);
    }

    public static <T> T fromJson(String json, Class<T> clazz) {
        return GSON.fromJson(json, clazz);
    }

    public static String json(Response response, int status, Object value) {
        response.status(status);
        response.type("application/json; charset=utf-8");
        return toJson(value);
    }
}
