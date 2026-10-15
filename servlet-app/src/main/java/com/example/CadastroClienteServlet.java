package com.example;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cadastro")
public class CadastroClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/cadastroT.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String nome = WebSupport.campo(request, "nome");
        String cpf = WebSupport.campo(request, "cpf").replaceAll("\\D", "");
        String telefone = WebSupport.campo(request, "telefone");
        String email = WebSupport.campo(request, "email");
        String senha = request.getParameter("senha");
        if (!WebSupport.preenchidos(nome, cpf, telefone, email, senha)
                || cpf.length() != 11 || nome.length() > 100 || telefone.length() > 20
                || email.length() > 150 || senha.length() < 8) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro",
                    "Preencha todos os campos. O CPF deve ter 11 dígitos e a senha ao menos 8 caracteres.");
            doGet(request, response);
            return;
        }
        try {
            ClienteRepository.cadastrar(nome, cpf, telefone, email, senha);
            response.sendRedirect(request.getContextPath() + "/login?cadastro=sucesso");
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "CPF ou e-mail já cadastrado.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
