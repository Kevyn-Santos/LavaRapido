package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.ClienteRepository;
import com.splash.web.db.LavaRapidoRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        if (!WebSupport.preenchidos(email, senha)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", "Preencha e-mail e senha.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        try {
            LavaRapidoRepository.Cliente cliente = ClienteRepository.autenticar(email, senha);
            if (cliente == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                request.setAttribute("erro", "E-mail ou senha inválidos.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }
            HttpSession sessaoAnterior = request.getSession(false);
            if (sessaoAnterior != null) {
                sessaoAnterior.invalidate();
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("clienteId", cliente.id());
            session.setAttribute("clienteNome", cliente.nome());
            response.sendRedirect(request.getContextPath() + "/portal");
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
