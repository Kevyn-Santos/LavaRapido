package com.splash.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.splash.web.db.DAO;
import com.splash.web.model.Cliente;

import java.io.IOException;
import java.net.http.HttpRequest;
import java.sql.SQLException;
@WebServlet("/mostrarCadastros")
public class MostrarCadastros extends HttpServlet{
    DAO daoConsulta = new DAO();

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        try {
            request.setAttribute("queryUsers", daoConsulta.getUsuarios());
            request.getRequestDispatcher("/WEB-INF/views/cadastro.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }


}
