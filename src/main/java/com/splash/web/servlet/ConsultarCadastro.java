package com.splash.web.servlet;

import com.splash.web.db.DAOCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

// Servlet de teste para DAOCliente.getusuario (não versionada)
@WebServlet("/consultarCadastro")
public class ConsultarCadastro extends HttpServlet {

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        DAOCliente daoCliente = new DAOCliente();

        try {
            int id = Integer.parseInt(request.getParameter("IdUser"));
            request.setAttribute("usuario", daoCliente.getusuario(id));
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", e.getMessage());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("erro", e.getMessage());
        }

        try {
            request.setAttribute("currentUsers", daoCliente.getUsuarios());
        } catch (SQLException e) {
            request.setAttribute("erro", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/ConsultarCadastro.jsp").forward(request, response);
    }
}
