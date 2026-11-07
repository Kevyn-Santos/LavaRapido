package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.api.Json;
import com.splash.web.api.dto.ServicoResponse;
import com.splash.web.db.DAOServico;
import com.splash.web.model.dto.ServicoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * {@code GET /api/v1/servicos -> [{id, nome, descricao, preco}]}. Rota pública (sem
 * autenticação), liberada no ApiAuthFilter.
 *
 * TODO: implementar usando DAOServico. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/servicos")
public class ServicoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOServico.listar()

        DAOServico dao = new DAOServico();

        try{

            for(ServicoView item: dao.listar()){
                ServicoResponse servico = new ServicoResponse(
                        item.getId(), item.getNome(), item.getDescricao(), item.getPreco()
                );

                String json = """
                        id_servico: %d,
                        nome: %s
                        descricao: %s
                        preco: %.2f
                        """.formatted(
                                servico.id_servico(),
                                servico.nome(),
                                servico.descricao(),
                                servico.preco()
                );

                Json.Response_enviar(response, HttpServletResponse.SC_OK ,json);
            }

        } catch (SQLException e) {
            Json.erro(response, HttpServletResponse.SC_NO_CONTENT, "Não foram encontrados serviços para listagem");
        }

        return;
    }
}
