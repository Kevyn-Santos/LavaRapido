package com.splash.web.servlet;

import com.splash.web.db.DAOCliente;
import com.splash.web.model.Validacao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.io.PrintWriter;

@WebServlet("/editarCadastro")
public class EditarCadastro extends HttpServlet {


    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        DAOCliente daoCliente = new DAOCliente();

        try {
            Integer id = Integer.parseInt(request.getParameter("IdUser"));
            String nome = request.getParameter("nome");
            String telefone = request.getParameter("telefone");
            String email = request.getParameter("email");

            if(!telefone.isBlank()) telefone = Validacao.telefone(telefone);
            if(!email.isBlank()) email = Validacao.email(email);

            daoCliente.updateUsuarios(id, nome, telefone, email);

            request.setAttribute("atualização", "Atualização realizada com sucesso!");
            request.getRequestDispatcher("/WEB-INF/views/EditarCadastro.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/EditarCadastro.jsp").forward(request, response);
            return;
        }catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("erro", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/EditarCadastro.jsp").forward(request, response);
            return;
        }

    }
}
