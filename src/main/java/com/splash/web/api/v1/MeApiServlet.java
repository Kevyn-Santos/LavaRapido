package com.splash.web.api.v1;

import java.io.IOException;

import com.splash.web.api.ApiServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * <pre>
 * GET   /api/v1/me -> {id, nome, cpf, telefone, email}
 * PATCH /api/v1/me {nome?, telefone?, email?}
 * </pre>
 *
 * TODO: implementar usando DAOCliente. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/me")
public class MeApiServlet extends ApiServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOCliente.getusuario(idClienteAutenticado(request))
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    @Override
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: DAOCliente.updateUsuarios(...)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
