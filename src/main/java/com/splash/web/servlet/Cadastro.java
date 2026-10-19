package com.splash.web.servlet;

import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import com.splash.web.security.Passwords;
import com.splash.web.security.Passwords.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

@WebServlet("/cadastro")
public class Cadastro extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        DAOCliente daoCliente = new DAOCliente();
        Cliente cliente = new Cliente();
        response.setContentType("text/plain; charset=UTF-8");

        try {
            cliente.setNome(request.getParameter("nome"));
            cliente.setCPF(request.getParameter("cpf"));
            cliente.setTelefone(request.getParameter("telefone"));
            cliente.setEmail(request.getParameter("email"));
            cliente.setSenhaHash(Passwords.hash(request.getParameter("senha")));
            daoCliente.insertUsuario(cliente);
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", e.getMessage());
            e.printStackTrace();
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }catch (SQLIntegrityConstraintViolationException e){
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            request.setAttribute("erro", e.getMessage());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }catch (SQLException e){
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("erro", e.getMessage());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }
        request.getRequestDispatcher("/mostrarCadastros").forward(request, response);


    }
}
