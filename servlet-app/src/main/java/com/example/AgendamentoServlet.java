package com.example;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

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
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        try {
            request.setAttribute("veiculos", LavaRapidoRepository.listarVeiculos(idCliente));
            request.setAttribute("servicos", LavaRapidoRepository.listarServicos());
            request.setAttribute("agendamentos", LavaRapidoRepository.listarAgendamentosCliente(idCliente));
            request.setAttribute("dataMinima", LocalDate.now());
            request.getRequestDispatcher("/agendamentos.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        String acao = WebSupport.campo(request, "acao");
        try {
            if ("cancelar".equals(acao)) {
                Integer id = WebSupport.inteiro(WebSupport.campo(request, "idAgendamento"));
                if (id == null || !LavaRapidoRepository.cancelarAgendamento(idCliente, id)) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    request.setAttribute("erro", "Agendamento não encontrado ou não pode mais ser cancelado.");
                    doGet(request, response);
                    return;
                }
            } else if ("agendar".equals(acao)) {
                Integer idVeiculo = WebSupport.inteiro(WebSupport.campo(request, "idVeiculo"));
                LocalDate data = LocalDate.parse(WebSupport.campo(request, "data"));
                LocalTime horario = LocalTime.parse(WebSupport.campo(request, "horario"));
                String[] ids = request.getParameterValues("idServicos");
                if (idVeiculo == null || data.isBefore(LocalDate.now()) || ids == null || ids.length == 0) {
                    throw new IllegalArgumentException("Selecione veículo, serviços e uma data válida.");
                }
                List<Integer> servicos = new ArrayList<>();
                for (String id : ids) {
                    Integer parsed = WebSupport.inteiro(id);
                    if (parsed == null || parsed <= 0) {
                        throw new IllegalArgumentException("A lista de serviços contém um item inválido.");
                    }
                    servicos.add(parsed);
                }
                LavaRapidoRepository.criarAgendamento(idCliente, idVeiculo, data, horario.toString(), servicos);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/agendamentos?sucesso=1");
        } catch (DateTimeParseException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", "Informe uma data e um horário válidos.");
            doGet(request, response);
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", exception.getMessage());
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
}
