package com.splash.web.api.v1;

import java.awt.*;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.stream.Collectors;

import com.splash.web.api.Json;
import com.splash.web.api.dto.NovoAgendamentoRequest;
import com.splash.web.db.DAOAgendamento;
import com.splash.web.model.dto.AgendamentoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

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

        DAOAgendamento dao = new DAOAgendamento();

        try {
            String jsonMobile = request.getReader().lines().collect(Collectors.joining());
            JSONObject jsonObject = new JSONObject(jsonMobile);
            int client = jsonObject.getInt("idcliente");

            for (AgendamentoView item:dao.listarPorCliente(client)){
                NovoAgendamentoRequest agendamento = new NovoAgendamentoRequest(
                        item.getIdCliente(),
                        item.getidVeiculo(),
                        item.getData(),
                        LocalTime.parse(item.getHorario()),
                        new ArrayList<>(item.getIdServico()),
                        item.getTotal(),
                        item.getStatusPagamento(),
                        item.getFormaPagamento()
                );

                String json = """
                        id_agendamento: %d,
                        id_veiculo: %d,
                        data_agendamento: %tY/%tm/%td,
                        hora_agendamento: %tT,
                        id_servico: [%s],
                        total_servico: %f,
                        status_pagamento: %s,
                        forma_pagamento: %s
                        """.formatted(
                                agendamento.idagendamento(),
                                agendamento.idVeiculo(),
                                agendamento.data(),
                                agendamento.data(),
                                agendamento.data(),
                                agendamento.horario(),
                                agendamento.idsServicos(),
                                agendamento.total(),
                                agendamento.statusPagamento(),
                                agendamento.formaPagamento()
                );

                Json.Response_ok(response, json);

            }



        } catch (SQLException e) {
            Json.erro(response, HttpServletResponse.SC_NO_CONTENT, "Não foram encontrados agendamentos para o cliente");
        }

        return;
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
