package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.api.Json;
import com.splash.web.db.DAOServico;
import com.splash.web.model.dto.ServicoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * {@code GET /api/v1/servicos -> [{id_servico, nome, descricao, preco}]}. Rota pública (sem
 * autenticação), liberada no ApiAuthFilter. Erro de banco: 500 com {@code {"erro": "..."}}.
 */
@WebServlet("/api/v1/servicos")
public class ServicoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            JSONArray lista = new JSONArray();

            for (ServicoView item : new DAOServico().listar()) {
                JSONObject servico = new JSONObject();
                servico.put("id_servico", item.getId());
                servico.put("nome", item.getNome());
                servico.put("descricao", Json.ouNulo(item.getDescricao()));
                // BigDecimal vira número JSON com ponto decimal (o %.2f dependia do locale: "10,50")
                servico.put("preco", item.getPreco());
                lista.put(servico);
            }

            // Uma única resposta com o array inteiro ([] quando não há serviços)
            Json.Response_ok(response, lista.toString());

        } catch (SQLException e) {
            getServletContext().log("Erro ao listar serviços", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }
}
