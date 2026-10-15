package com.example;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/portal")
public class PortalServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession(false) != null
                && request.getSession(false).getAttribute("clienteId") != null) {
            request.getRequestDispatcher("/portal.jsp").forward(request, response);
            return;
        }
        if (request.getSession(false) != null
                && request.getSession(false).getAttribute("colaboradorId") != null) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/");
    }
}
