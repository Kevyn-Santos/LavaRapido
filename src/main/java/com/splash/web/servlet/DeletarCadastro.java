package com.splash.web.servlet;

import com.splash.web.db.DAOCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

// Servlet de teste para DAOCliente.deleteusuario (deleteusuariosTotal foi removido: fazia o mesmo DELETE, ver 6.6)
@WebServlet("/deletarCadastro")
public class DeletarCadastro extends HttpServlet {

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        DAOCliente daoCliente = new DAOCliente();

        try {
            int id = Integer.parseInt(request.getParameter("IdUser"));
            daoCliente.deleteusuario(id);
            request.setAttribute("sucesso", "Dados deletados com sucesso (id " + id + ")");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", e.getMessage());
        } catch (SQLIntegrityConstraintViolationException e) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            request.setAttribute("erro", e.getMessage());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("erro", e.getMessage());
        }

        // Recarrega a lista para o select refletir a exclusão
        try {
            request.setAttribute("currentUsers", daoCliente.getUsuarios());
        } catch (SQLException e) {
            request.setAttribute("erro", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/DeletarCadastro.jsp").forward(request, response);
    }
}
