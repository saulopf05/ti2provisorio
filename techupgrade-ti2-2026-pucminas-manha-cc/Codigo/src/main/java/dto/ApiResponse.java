package dto;

public class ApiResponse {
    public boolean sucesso;
    public String mensagem;

    public ApiResponse(boolean sucesso, String mensagem) {
        this.sucesso = sucesso;
        this.mensagem = mensagem;
    }
}
