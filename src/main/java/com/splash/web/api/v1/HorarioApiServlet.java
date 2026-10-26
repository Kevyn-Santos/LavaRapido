package com.splash.web.api.v1;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * {@code GET /api/v1/horarios?data=2026-10-20 -> ["08:00", "08:30", ...]} (horários livres).
 *
 * TODO: implementar. Resolve o erro E1 (horário sem validação) descrito em
 * miscelaneous/analise-app-mobile.md, seções 1.5 e 3.5.
 */
@WebServlet("/api/v1/horarios")
public class HorarioApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: calcular horários livres para a data informada (parâmetro "data")
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
