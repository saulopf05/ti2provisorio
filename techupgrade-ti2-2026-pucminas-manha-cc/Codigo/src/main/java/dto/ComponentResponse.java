package dto;

public class ComponentResponse {
    public String id;
    public String tipo;
    public String nome;
    public String specAtual;
    public String status;
    public String mensagem;
    public String recomendacao;
    public String precoMedio;
    public String linkCompra;

    public ComponentResponse(String id, String tipo, String nome, String specAtual, String status, String mensagem,
                             String recomendacao, String precoMedio, String linkCompra) {
        this.id = id;
        this.tipo = tipo;
        this.nome = nome;
        this.specAtual = specAtual;
        this.status = status;
        this.mensagem = mensagem;
        this.recomendacao = recomendacao;
        this.precoMedio = precoMedio;
        this.linkCompra = linkCompra;
    }
}
