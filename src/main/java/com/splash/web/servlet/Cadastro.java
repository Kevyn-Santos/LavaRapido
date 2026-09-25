package com.splash.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.splash.web.db.DAO;
import com.splash.web.model.Cliente;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/cadastro")
public class Cadastro extends HttpServlet {
    DAO dao = new DAO();
    Cliente cliente = new Cliente();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{

        try {
            cliente.setNome(request.getParameter("nome"));
            cliente.setCpf(request.getParameter("cpf"));
            cliente.setTelefone(request.getParameter("telefone"));
            cliente.setEmail(request.getParameter("email"));
            cliente.setSenha(request.getParameter("senha"));
        } catch (RuntimeException e) {
            throw new RuntimeException(e);
        }

        try {
            dao.insertUsuario(cliente);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
            request.getRequestDispatcher("/WEB-INF/views/cadastro.jsp").forward(request, response);
    }


}
