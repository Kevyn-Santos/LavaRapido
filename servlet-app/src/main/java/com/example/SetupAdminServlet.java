package com.example;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/setup/admin")
public class SetupAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!configurado(request, response)) {
            return;
        }
        try {
            if (LavaRapidoRepository.existeAdministrador()) {
                response.sendError(HttpServletResponse.SC_GONE, "A configuração inicial já foi concluída.");
                return;
            }
            request.getRequestDispatcher("/setup-admin.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!configurado(request, response)) {
            return;
        }
        String token = request.getParameter("token");
        String tokenConfigurado = System.getenv("INITIAL_ADMIN_TOKEN");
        if (token == null || !MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8),
                tokenConfigurado.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Token de configuração inválido.");
            return;
        }
        String nome = WebSupport.campo(request, "nome");
        String cargo = WebSupport.campo(request, "cargo");
        String email = WebSupport.campo(request, "email");
        String senha = request.getParameter("senha");
        if (!WebSupport.preenchidos(nome, cargo, email, senha) || nome.length() > 100
                || cargo.length() > 60 || email.length() > 150 || senha.length() < 8) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", "Preencha os campos; a senha deve ter ao menos 8 caracteres.");
            request.getRequestDispatcher("/setup-admin.jsp").forward(request, response);
            return;
        }
        try {
            LavaRapidoRepository.criarAdministradorInicial(nome, cargo, email, senha);
            response.sendRedirect(request.getContextPath() + "/colaborador/login?setup=sucesso");
        } catch (IllegalStateException exception) {
            response.sendError(HttpServletResponse.SC_GONE, "A configuração inicial já foi concluída.");
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "Este e-mail já está cadastrado.");
                request.getRequestDispatcher("/setup-admin.jsp").forward(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }

    private boolean configurado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = System.getenv("INITIAL_ADMIN_TOKEN");
        if (token == null || token.isBlank()) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            request.setAttribute("configuracaoIndisponivel", true);
            request.getRequestDispatcher("/setup-admin.jsp").forward(request, response);
            return false;
        }
        return true;
    }
}
