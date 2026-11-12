package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

import com.splash.web.api.Json;
import com.splash.web.db.DAOAgendamento;
import com.splash.web.model.dto.AgendamentoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * <pre>
 * GET  /api/v1/agendamentos?idcliente=1   -> [{id_agendamento, id_veiculo, data_agendamento, hora_agendamento,
 *                                              id_servico[], total_servico, status_pagamento, forma_pagamento}]
 * POST /api/v1/agendamentos               {idcliente, idveiculo, dataAgendamento (dd/MM/yyyy),
 *                                          horarioAgendamento, idservico[]} -> 201 {mensagem}
 * POST /api/v1/agendamentos/{id}/cancelar -> 204
 * </pre>
 *
 * Erros: sempre {@code {"erro": "mensagem"}} (ver {@link Json#erro}).
 * TODO: o {@code idcliente} deve vir do token quando a autenticação for implementada.
 */
@WebServlet("/api/v1/agendamentos/*")
public class AgendamentoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // GET não tem corpo confiável: o cliente vem na query string (?idcliente=1)
        int idCliente;
        try {
            idCliente = Json.parametroInt(request, "idcliente");
        } catch (IllegalArgumentException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        try {
            DateTimeFormatter formatoData = DateTimeFormatter.ofPattern("yyyy/MM/dd");
            JSONArray lista = new JSONArray();

            for (AgendamentoView item : new DAOAgendamento().listarPorCliente(idCliente)) {
                JSONObject agendamento = new JSONObject();
                agendamento.put("id_agendamento", item.getIdAgendamento());
                agendamento.put("id_veiculo", item.getidVeiculo());
                agendamento.put("data_agendamento", item.getData().format(formatoData));
                agendamento.put("hora_agendamento", item.getHorario());
                agendamento.put("id_servico", new JSONArray(item.getIdServico()));
                agendamento.put("total_servico", item.getTotal());
                agendamento.put("status_pagamento", Json.ouNulo(item.getStatusPagamento()));
                agendamento.put("forma_pagamento", Json.ouNulo(item.getFormaPagamento()));
                lista.put(agendamento);
            }

            // Uma única resposta com o array inteiro ([] quando o cliente não tem agendamentos)
            Json.Response_ok(response, lista.toString());

        } catch (SQLException e) {
            getServletContext().log("Erro ao listar agendamentos do cliente " + idCliente, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
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
        try {
            JSONObject corpo = Json.lerCorpo(request);
            int idCliente = corpo.getInt("idcliente");
            int idVeiculo = corpo.getInt("idveiculo");
            String horario = corpo.getString("horarioAgendamento");
            LocalDate data = LocalDate.parse(corpo.getString("dataAgendamento"),
                    DateTimeFormatter.ofPattern("dd/MM/yyyy"));

            JSONArray servicos = corpo.getJSONArray("idservico");
            List<Integer> idsServicos = new ArrayList<>();
            for (int i = 0; i < servicos.length(); i++) {
                idsServicos.add(servicos.getInt(i));
            }

            new DAOAgendamento().criar(idCliente, idVeiculo, data, horario, idsServicos);

            Json.Response_enviar(response, HttpServletResponse.SC_CREATED,
                    new JSONObject().put("mensagem", "Agendamento criado com sucesso").toString());

        } catch (JSONException | DateTimeParseException e) {
            // corpo vazio/inválido, campo ausente ou com tipo errado, data fora de dd/MM/yyyy
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            // regra de negócio da DAO (veículo inativo, serviço inexistente/repetido...)
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
        } catch (SQLException e) {
            getServletContext().log("Erro ao criar agendamento", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    private void cancelar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOAgendamento.cancelar(idCliente, id) com o id lido do pathInfo (/{id}/cancelar)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
