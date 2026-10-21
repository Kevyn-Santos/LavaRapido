package com.splash.web.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Tela de baixar o app, mostrada depois do cadastro. {@code CadastroClienteServlet} redireciona para cá
 * (Post/Redirect/Get), assim recarregar a página não reenvia o formulário de cadastro.
 */
@WebServlet("/baixar-app")
public class BaixarAppServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/baixar-app.jsp").forward(request, response);
    }
}
