
package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

import com.splash.web.db.DAOAgendamento;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/agendamentos")
public class AdminAgendamentoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (WebSupport.colaboradorId(
                request, response, "OPERACIONAL") < 0) {
            return;
        }

        try {
            String acao = WebSupport.campo(request, "acao");

            if (!"agendar".equals(acao)) {
                throw new IllegalArgumentException(
                    "Ação de agendamento inválida."
                );
            }

            Integer idCliente = WebSupport.inteiro(
                WebSupport.campo(request, "idCliente")
            );

            Integer idVeiculo = WebSupport.inteiro(
                WebSupport.campo(request, "idVeiculo")
            );

            if (idCliente == null || idCliente <= 0
                    || idVeiculo == null || idVeiculo <= 0) {
                throw new IllegalArgumentException(
                    "Selecione um cliente e um veículo válidos."
                );
            }

            LocalDate data = LocalDate.parse(
                WebSupport.campo(request, "data")
            );

            LocalTime horario = LocalTime.parse(
                WebSupport.campo(request, "horario")
            );

            if (data.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException(
                    "Não é possível agendar uma data anterior à atual."
                );
            }

            String[] idsRecebidos =
                request.getParameterValues("idServicos");

            if (idsRecebidos == null || idsRecebidos.length == 0) {
                throw new IllegalArgumentException(
                    "Selecione pelo menos um serviço."
                );
            }

            List<Integer> idsServicos = new ArrayList<>();

            for (String valor : idsRecebidos) {

                Integer idServico = WebSupport.inteiro(valor);

                if (idServico == null || idServico <= 0) {
                    throw new IllegalArgumentException(
                        "Um dos serviços selecionados é inválido."
                    );
                }

                idsServicos.add(idServico);
            }

            DAOAgendamento dao = new DAOAgendamento();

            dao.criar(
                idCliente,
                idVeiculo,
                data,
                horario.toString(),
                idsServicos
            );

            response.sendRedirect(
                request.getContextPath()
                + "/painel/agendamentos?sucesso=1"
            );

        } catch (DateTimeParseException |
                 IllegalArgumentException exception) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                exception.getMessage() == null
                    ? "Dados do agendamento inválidos."
                    : exception.getMessage()
            );

        } catch (SQLException exception) {

            if (exception.getSQLState() != null
                    && exception.getSQLState().startsWith("23")) {

                response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "Conflito ao cadastrar o agendamento. "
                    + "Verifique a disponibilidade do veículo e horário."
                );
                return;
            }

            WebSupport.erroBanco(request, response, exception);
        }
    }
}
