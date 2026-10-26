package com.splash.web.api.v1;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * <pre>
 * GET  /api/v1/agendamentos               -> [{id, placa, veiculo, data, horario, status, total, statusPagamento, formaPagamento}]
 * POST /api/v1/agendamentos               {idVeiculo, data, horario, idsServicos} -> 201
 * POST /api/v1/agendamentos/{id}/cancelar -> 204
 * </pre>
 *
 * TODO: implementar usando DAOAgendamento. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/agendamentos/*")
public class AgendamentoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOAgendamento.listarPorCliente(idCliente)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String rota = request.getPathInfo();
        if (rota != null && rota.endsWith("/cancelar")) {
            cancelar(request, response);
        } else {
            criar(request, response);
        }
    }

    private void criar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOAgendamento.criar(idCliente, idVeiculo, data, horario, idsServicos)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    private void cancelar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOAgendamento.cancelar(idCliente, id) com o id lido do pathInfo (/{id}/cancelar)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
