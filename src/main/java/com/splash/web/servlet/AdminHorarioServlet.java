package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

import com.splash.web.api.Json;
import com.splash.web.db.DAOAgendamento;
import com.splash.web.model.GradeHorarios;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;

/**
 * <pre>
 * GET /admin/horarios?data=2026-11-20 -> ["06:00", "06:30", ...]
 * </pre>
 *
 * Horários livres de uma data para o formulário de novo agendamento do painel ({@code painel-agendamentos.jsp}).
 * Usa a mesma regra da API mobile ({@link DAOAgendamento#horariosLivres}), mas com a sessão do colaborador
 * (nível OPERACIONAL, o mesmo de {@code POST /admin/agendamentos}) e a data em {@code yyyy-MM-dd}, formato do
 * {@code <input type="date">}. Erros: 400 com data ausente/inválida, 500 com erro de banco, sempre
 * {@code {"erro": ...}}. Registro: miscelaneous/ajustes-agendamento-atendimento-painel.md.
 */
@WebServlet("/admin/horarios")
public class AdminHorarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (WebSupport.colaboradorId(request, response, "OPERACIONAL") < 0) {
            return;
        }
        // A disponibilidade muda a cada agendamento: nunca pode vir de cache
        response.setHeader("Cache-Control", "no-store");

        LocalDate data;
        try {
            data = LocalDate.parse(WebSupport.campo(request, "data"));
        } catch (DateTimeParseException exception) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST, "Informe uma data válida.");
            return;
        }
        try {
            JSONArray lista = new JSONArray();
            for (LocalTime horario : new DAOAgendamento().horariosLivres(data)) {
                lista.put(horario.format(GradeHorarios.FORMATO));
            }
            Json.Response_ok(response, lista.toString());
        } catch (SQLException exception) {
            getServletContext().log("Erro ao listar horários livres de " + data, exception);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Não foi possível consultar os horários. Tente novamente.");
        }
    }
}
