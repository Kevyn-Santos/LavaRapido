package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

import com.splash.web.db.DAOAgendamento;
import com.splash.web.db.DAOServico;
import com.splash.web.db.DAOVeiculo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/agendamentos")
public class AgendamentoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int clienteId = WebSupport.clienteId(request, response);
        if (clienteId < 0) {
            return;
        }
        try {
            carregarDados(request, clienteId);
            request.setAttribute("dataMinima", LocalDate.now());
            request.getRequestDispatcher("/WEB-INF/views/agendamentos.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int clienteId = WebSupport.clienteId(request, response);
        if (clienteId < 0) {
            return;
        }
        DAOAgendamento daoAgendamento = new DAOAgendamento();
        String acao = WebSupport.campo(request, "acao");
        try {
            if ("cancelar".equals(acao)) {
                Integer id = WebSupport.inteiro(WebSupport.campo(request, "idAgendamento"));
                if (id == null || !daoAgendamento.cancelar(clienteId, id)) {
                    request.setAttribute("erro", "Agendamento não encontrado ou não pode mais ser cancelado.");
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    doGet(request, response);
                    return;
                }
            } else if ("agendar".equals(acao)) {
                Integer idVeiculo = WebSupport.inteiro(WebSupport.campo(request, "idVeiculo"));
                LocalDate data = LocalDate.parse(WebSupport.campo(request, "data"));
                LocalTime horario = LocalTime.parse(WebSupport.campo(request, "horario"));
                String[] idsRecebidos = request.getParameterValues("idServicos");
                if (idVeiculo == null || data.isBefore(LocalDate.now()) || idsRecebidos == null
                        || idsRecebidos.length == 0) {
                    throw new IllegalArgumentException("Selecione um veículo, ao menos um serviço e uma data válida.");
                }
                List<Integer> idsServicos = new ArrayList<>();
                for (String id : idsRecebidos) {
                    Integer valor = WebSupport.inteiro(id);
                    if (valor == null || valor <= 0) {
                        throw new IllegalArgumentException("A lista de serviços contém um item inválido.");
                    }
                    idsServicos.add(valor);
                }
                daoAgendamento.criar(clienteId, idVeiculo, data, horario.toString(), idsServicos);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/agendamentos?sucesso=1");
        } catch (DateTimeParseException | IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", exception.getMessage() == null
                    ? "Informe uma data e um horário válidos." : exception.getMessage());
            doGet(request, response);
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "Este veículo já possui um agendamento nesse dia e horário.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }

    private void carregarDados(HttpServletRequest request, int clienteId) throws SQLException {
        request.setAttribute("veiculos", new DAOVeiculo().listarPorCliente(clienteId));
        request.setAttribute("servicos", new DAOServico().listar());
        request.setAttribute("agendamentos", new DAOAgendamento().listarPorCliente(clienteId));
    }
}
