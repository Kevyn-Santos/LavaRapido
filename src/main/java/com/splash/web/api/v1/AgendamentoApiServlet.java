package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import com.splash.web.api.ApiAuthFilter;
import com.splash.web.api.Json;
import com.splash.web.db.DAOAgendamento;
import com.splash.web.db.DAOPagamento;
import com.splash.web.model.dto.AgendamentoView;
import com.splash.web.model.dto.ServicoView;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * <pre>
 * GET  /api/v1/agendamentos                -> [{id_agendamento, id_veiculo, data_agendamento, hora_agendamento,
 *                                              id_servico[], servicos[{id_servico, nome, valor}],
 *                                              total_servico, status, status_atendimento,
 *                                              status_pagamento, forma_pagamento}]
 *                                              (data em yyyy-MM-dd; status_atendimento é null se não houver)
 * POST /api/v1/agendamentos               {idveiculo, dataAgendamento (yyyy-MM-dd),
 *                                          horarioAgendamento (HH:mm, grade 06:00-17:30 de 30 em 30 min),
 *                                          idservico[]} -> 201 {mensagem}; 422 se o horário estiver
 *                                          fora da grade, já passado ou indisponível (ver GET /horarios)
 * POST /api/v1/agendamentos/{id}/cancelar -> 200 {mensagem}; 404 se não existir, for de outro cliente
 *                                            ou não estiver AGENDADO
 * POST /api/v1/agendamentos/{id}/pagar {forma: PIX|CREDITO|DEBITO} -> 200 {mensagem, status_pagamento, forma_pagamento};
 *                                            422 forma inválida, 404 se não for do cliente, 409 se o pagamento
 *                                            já foi processado (ex.: o atendente marcou como pago no site)
 * </pre>
 *
 * Erros: sempre {@code {"erro": "mensagem"}} (ver {@link Json#erro}).
 * Autenticação: o cliente é o da sessão (ver {@link ApiAuthFilter}); o app não
 * envia {@code idcliente}.
 */
@WebServlet("/api/v1/agendamentos/*")
public class AgendamentoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // O cliente vem da sessão (ApiAuthFilter), nunca da URL
        int idCliente = ApiAuthFilter.idAutenticado(request);

        try {
            JSONArray lista = new JSONArray();

            for (AgendamentoView item : new DAOAgendamento().listarPorCliente(idCliente)) {
                JSONObject agendamento = new JSONObject();
                agendamento.put("id_agendamento", item.getIdAgendamento());
                agendamento.put("id_veiculo", item.getidVeiculo());
                agendamento.put("data_agendamento", item.getData().toString()); // ISO yyyy-MM-dd
                agendamento.put("hora_agendamento", item.getHorario());
                agendamento.put("id_servico", new JSONArray(item.getIdServico()));
                JSONArray servicos = new JSONArray();
                for (ServicoView servico : item.getServicos()) {
                    // "valor" = valor praticado na época do agendamento (não o preço atual do
                    // catálogo)
                    servicos.put(new JSONObject()
                            .put("id_servico", servico.getId())
                            .put("nome", servico.getNome())
                            .put("valor", servico.getPreco()));
                }
                agendamento.put("servicos", servicos);
                agendamento.put("total_servico", item.getTotal());
                agendamento.put("status", Json.ouNulo(item.getStatus()));
                agendamento.put("status_atendimento", Json.ouNulo(item.getStatusAtendimento()));
                agendamento.put("status_pagamento", Json.ouNulo(item.getStatusPagamento()));
                agendamento.put("forma_pagamento", Json.ouNulo(item.getFormaPagamento()));
                lista.put(agendamento);
            }

            // Uma única resposta com o array inteiro ([] quando o cliente não tem
            // agendamentos)
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
        } else if (rota != null && rota.endsWith("/pagar")) {
            pagar(request, response);
        } else {
            criar(request, response);
        }
    }

    private void criar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            JSONObject corpo = Json.lerCorpo(request);
            int idCliente = ApiAuthFilter.idAutenticado(request);
            int idVeiculo = corpo.getInt("idveiculo");
            String horario = corpo.getString("horarioAgendamento");
            LocalDate data = LocalDate.parse(corpo.getString("dataAgendamento"));

            JSONArray servicos = corpo.getJSONArray("idservico");
            List<Integer> idsServicos = new ArrayList<>();
            for (int i = 0; i < servicos.length(); i++) {
                idsServicos.add(servicos.getInt(i));
            }

            new DAOAgendamento().criar(
                    idCliente,
                    idVeiculo,
                    data,
                    horario,
                    idsServicos,
                    "CLIENTE",
                    null);

            Json.Response_enviar(response, HttpServletResponse.SC_CREATED,
                    new JSONObject().put("mensagem", "Agendamento criado com sucesso").toString());

        } catch (DateTimeParseException e) {
            // a mensagem do Java é em inglês: texto fixo em português
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Data inválida. Use yyyy-MM-dd");
        } catch (JSONException e) {
            // corpo vazio/inválido, campo ausente ou com tipo errado
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            // regra de negócio da DAO (veículo inativo, serviço inexistente/repetido...)
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT, e.getMessage());
        } catch (SQLException e) {
            getServletContext().log("Erro ao criar agendamento", e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    /**
     * Formas que o cliente pode escolher no app (DINHEIRO só o atendente registra,
     * no site).
     */
    private static final Set<String> FORMAS_DO_APP = Set.of("PIX", "CREDITO", "DEBITO");

    private void pagar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int idCliente = ApiAuthFilter.idAutenticado(request);
        String[] partes = request.getPathInfo().split("/"); // "", "{id}", "pagar"
        int idAgendamento;
        String forma;
        try {
            if (partes.length != 3) {
                throw new NumberFormatException();
            }
            idAgendamento = Integer.parseInt(partes[1]);
        } catch (NumberFormatException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Informe o agendamento no caminho: /api/v1/agendamentos/{idAgendamento}/pagar");
            return;
        }
        try {
            forma = Json.lerCorpo(request).getString("forma");
        } catch (JSONException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Requisição inválida: " + e.getMessage());
            return;
        }
        if (!FORMAS_DO_APP.contains(forma)) {
            Json.erro(response, HttpServletResponse.SC_UNPROCESSABLE_CONTENT,
                    "Forma de pagamento inválida. Use PIX, CREDITO ou DEBITO");
            return;
        }

        try {
            DAOPagamento dao = new DAOPagamento();
            Integer idPagamento = dao.idDoAgendamentoDoCliente(idCliente, idAgendamento);
            if (idPagamento == null) {
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND, "Agendamento não encontrado");
                return;
            }
            try {
                dao.atualizar(idPagamento, "PAGO", forma);
            } catch (IllegalArgumentException e) {
                // não está PENDENTE (já pago/cancelado) ou o agendamento foi cancelado
                Json.erro(response, HttpServletResponse.SC_CONFLICT, e.getMessage());
                return;
            }
            Json.Response_ok(response, new JSONObject()
                    .put("mensagem", "Pagamento do agendamento %d confirmado".formatted(idAgendamento))
                    .put("status_pagamento", "PAGO")
                    .put("forma_pagamento", forma).toString());
        } catch (SQLException e) {
            getServletContext().log("Erro ao pagar agendamento " + idAgendamento, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }

    private void cancelar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // O cliente vem da sessão (ApiAuthFilter); o agendamento, do path
        // (/{id}/cancelar)
        int idCliente = ApiAuthFilter.idAutenticado(request);
        int idAgendamento;
        String[] partes = request.getPathInfo().split("/"); // "", "{id}", "cancelar"
        try {
            if (partes.length != 3) {
                throw new NumberFormatException();
            }
            idAgendamento = Integer.parseInt(partes[1]);
        } catch (NumberFormatException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Informe o agendamento no caminho: /api/v1/agendamentos/{idAgendamento}/cancelar");
            return;
        }

        try {
            if (new DAOAgendamento().cancelar(idCliente, idAgendamento)) {
                Json.Response_ok(response, new JSONObject()
                        .put("mensagem", "Agendamento %d cancelado com sucesso".formatted(idAgendamento))
                        .toString());
            } else {
                // Mesma resposta para id inexistente, de outro cliente ou já fora do status
                // AGENDADO
                Json.erro(response, HttpServletResponse.SC_NOT_FOUND,
                        "Agendamento não encontrado ou não pode ser cancelado");
            }
        } catch (SQLException e) {
            getServletContext().log("Erro ao cancelar agendamento " + idAgendamento, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }
}
