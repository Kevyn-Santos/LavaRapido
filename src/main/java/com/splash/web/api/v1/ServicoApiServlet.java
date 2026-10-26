package com.splash.web.api.v1;

import java.io.IOException;

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
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
