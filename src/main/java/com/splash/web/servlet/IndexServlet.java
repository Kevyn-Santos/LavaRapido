package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.DAOServico;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("")
public class IndexServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("servicos", new DAOServico().listar());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
