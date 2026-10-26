package com.splash.web.api;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Base para os servlets de {@code /api/v1/*}. Dá suporte a PATCH (sem método dedicado em
 * HttpServlet) e expõe o id do cliente autenticado, posto pelo ApiAuthFilter.
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

    /** Id do cliente autenticado, posto por {@link ApiAuthFilter}. -1 se não houver. */
    protected int idClienteAutenticado(HttpServletRequest request) {
        Object id = request.getAttribute("idCliente");
        return id instanceof Integer idCliente ? idCliente : -1;
    }
}
