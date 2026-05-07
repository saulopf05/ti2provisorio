package util;

import spark.Request;

public class HttpUtil {
    public static String bearerToken(Request request) {
        String header = request.headers("Authorization");
        if (header == null) return null;
        if (!header.toLowerCase().startsWith("bearer ")) return null;
        return header.substring(7).trim();
    }
}
