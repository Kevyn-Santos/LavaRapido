package com.splash.web.servlet;


import com.splash.web.db.DAOCliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/listarCadastros")
public class Listarcadastros extends HttpServlet {


    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException{
        DAOCliente daoCliente = new DAOCliente();
        try{
            request.setAttribute("currentUsers", daoCliente.getUsuarios());
            request.getRequestDispatcher("/WEB-INF/views/EditarCadastro.jsp").forward(request, response);

        } catch (RuntimeException | SQLException | ServletException e) {
            throw new RuntimeException(e);
        }
    }
}
