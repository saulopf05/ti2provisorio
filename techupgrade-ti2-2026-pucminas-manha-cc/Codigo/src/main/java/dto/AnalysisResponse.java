package dto;

import java.util.List;

public class AnalysisResponse {
    public String id;
    public String objetivo;
    public String resumo;
    public String textoExtraido;
    public List<ComponentResponse> componentes;

    public AnalysisResponse(String id, String objetivo, String resumo, String textoExtraido, List<ComponentResponse> componentes) {
        this.id = id;
        this.objetivo = objetivo;
        this.resumo = resumo;
        this.textoExtraido = textoExtraido;
        this.componentes = componentes;
    }
}
