package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.LavaRapidoRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/colaborador/login")
public class ColaboradorLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/colaborador-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = WebSupport.campo(request, "email");
        String senha = request.getParameter("senha");
        if (!WebSupport.preenchidos(email, senha)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", "Preencha e-mail e senha.");
            doGet(request, response);
            return;
        }
        try {
            LavaRapidoRepository.Colaborador colaborador =
                    LavaRapidoRepository.autenticarColaborador(email, senha);
            if (colaborador == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                request.setAttribute("erro", "E-mail ou senha inválidos.");
                doGet(request, response);
                return;
            }
            HttpSession sessaoAnterior = request.getSession(false);
            if (sessaoAnterior != null) {
                sessaoAnterior.invalidate();
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("colaboradorId", colaborador.id());
            session.setAttribute("colaboradorNome", colaborador.nome());
            session.setAttribute("nivelAcesso", colaborador.nivelAcesso());
            response.sendRedirect(request.getContextPath() + "/admin");
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
