package com.splash.web.api.v1;

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
 * GET /api/v1/horarios?data=2026-10-20 -> ["06:00", "06:30", ...]
 * </pre>
 *
 * Horários livres da data (formato ISO {@code yyyy-MM-dd}, o mesmo do {@code POST /agendamentos}). A grade
 * é de 06:00 a 17:30, de 30 em 30 minutos, com um agendamento por horário ({@link GradeHorarios}).
 * Data passada → {@code []}; hoje → só horários que ainda não passaram. Exige sessão (ApiAuthFilter).
 * Erros: 400 sem {@code data} ou com formato inválido, 500 erro de banco, sempre {@code {"erro": ...}}.
 * Registro: miscelaneous/horarios-api-mobile.md.
 */
@WebServlet("/api/v1/horarios")
public class HorarioApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        LocalDate data;
        try {
            data = LocalDate.parse(String.valueOf(request.getParameter("data")));
        } catch (DateTimeParseException e) {
            Json.erro(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Parâmetro 'data' ausente ou inválido. Use yyyy-MM-dd");
            return;
        }

        try {
            JSONArray lista = new JSONArray();
            for (LocalTime horario : new DAOAgendamento().horariosLivres(data)) {
                lista.put(horario.format(GradeHorarios.FORMATO));
            }
            Json.Response_ok(response, lista.toString());

        } catch (SQLException e) {
            getServletContext().log("Erro ao listar horários livres de " + data, e);
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro no acesso ao banco");
        }
    }
}
