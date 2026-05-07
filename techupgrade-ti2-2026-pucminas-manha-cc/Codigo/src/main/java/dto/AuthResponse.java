package dto;

public class AuthResponse {
    public String token;
    public UserResponse usuario;

    public AuthResponse(String token, UserResponse usuario) {
        this.token = token;
        this.usuario = usuario;
    }
}
