package com.splash.web.api.v1;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Rotas públicas de autenticação (sem passar pelo ApiAuthFilter).
 *
 * <pre>
 * POST /api/v1/auth/login    {cpf, senha}                       -> {token, cliente}
 * POST /api/v1/auth/cadastro {nome, cpf, telefone, email, senha} -> 201
 * </pre>
 *
 * TODO: implementar usando DAOCliente e Passwords (BCrypt).
 * Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/auth/*")
public class AuthApiServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String rota = request.getPathInfo();
        if ("/login".equals(rota)) {
            login(request, response);
        } else if ("/cadastro".equals(rota)) {
            cadastro(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOCliente.autenticarPorCpf(cpf, senha) + JwtService.gerar(idCliente)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }

    private void cadastro(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOCliente.cadastrar(nome, cpf, telefone, email, senha)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
