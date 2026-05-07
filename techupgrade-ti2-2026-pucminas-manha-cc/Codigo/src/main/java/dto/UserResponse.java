package dto;

public class UserResponse {
    public long id;
    public String nome;
    public String email;
    public String dataCadastro;

    public UserResponse(long id, String nome, String email, String dataCadastro) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.dataCadastro = dataCadastro;
    }
}
