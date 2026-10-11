package com.splash.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.splash.web.db.DAOCliente;

import java.io.IOException;
import java.sql.SQLException;
@WebServlet("/mostrarCadastros")
public class MostrarCadastros extends HttpServlet{
    DAOCliente daoClienteConsulta = new DAOCliente();

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        try {
            request.setAttribute("queryUsers", daoClienteConsulta.getUsuarios());
            request.getRequestDispatcher("/WEB-INF/views/cadastro.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

}
