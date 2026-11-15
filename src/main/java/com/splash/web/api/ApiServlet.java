package com.splash.web.api;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Base para os servlets de {@code /api/v1/*}. Dá suporte a PATCH (sem método dedicado em
 * HttpServlet). Hoje só {@code ClienteApiServlet} (PATCH) a estende; todos os servlets leem o
 * cliente autenticado por {@code ApiAuthFilter.idAutenticado}.
 */
public abstract class ApiServlet extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("PATCH".equalsIgnoreCase(request.getMethod())) {
            doPatch(request, response);
            return;
        }
        super.service(request, response);
    }

    /** Sobrescrever nos servlets que aceitam PATCH. */
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
