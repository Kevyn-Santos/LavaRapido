package com.splash.web.servlet;

import com.splash.web.db.DAOCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

// Servlet de teste para DAOCliente.getUsuariosVeiculo (não versionada)
@WebServlet("/listarClientesVeiculos")
public class ListarClientesVeiculos extends HttpServlet {

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        DAOCliente daoCliente = new DAOCliente();

        // Erros vão para a JSP (e não RuntimeException) para ser possível ver a falha da DAO na tela
        try {
            request.setAttribute("clientesVeiculos", daoCliente.getUsuariosVeiculo());
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", e.getMessage());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("erro", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/ListarClientesVeiculos.jsp").forward(request, response);
    }
}
