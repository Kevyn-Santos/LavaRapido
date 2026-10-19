package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import com.splash.web.security.Passwords;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Único cadastro de cliente (substitui a servlet {@code Cadastro}, que usava a mesma rota).
 *
 * <p>GET mostra o formulário {@code cadastro.jsp}. POST valida os campos pelo modelo {@link Cliente}
 * (via {@code Validacao}), gera o hash da senha e grava com {@link DAOCliente#insertUsuario(Cliente)}.</p>
 */
@WebServlet("/cadastro")
public class CadastroClienteServlet extends HttpServlet {

    private static final String FORMULARIO = "/cadastro.jsp";
    private static final int SENHA_MINIMA = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(FORMULARIO).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String senha = request.getParameter("senha");

        try {
            // O tamanho mínimo é conferido antes do hash, porque o hash BCrypt sempre tem 60 caracteres
            if (senha == null || senha.length() < SENHA_MINIMA) {
                throw new IllegalArgumentException("A senha deve ter ao menos " + SENHA_MINIMA + " caracteres.");
            }
            // O construtor valida e normaliza nome, CPF, telefone e e-mail
            Cliente cliente = new Cliente(WebSupport.campo(request, "nome"), WebSupport.campo(request, "cpf"),
                    WebSupport.campo(request, "telefone"), WebSupport.campo(request, "email"),
                    Passwords.hash(senha));
            new DAOCliente().insertUsuario(cliente);
            response.sendRedirect(request.getContextPath() + "/login?cadastro=sucesso");
        } catch (IllegalArgumentException exception) {
            voltarAoFormulario(request, response, HttpServletResponse.SC_BAD_REQUEST, exception.getMessage());
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                voltarAoFormulario(request, response, HttpServletResponse.SC_CONFLICT, "CPF ou e-mail já cadastrado.");
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }

    // Os campos digitados voltam pelo ${param.x} do formulário; a senha não é devolvida
    private void voltarAoFormulario(HttpServletRequest request, HttpServletResponse response, int status,
            String erro) throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("erro", erro);
        request.getRequestDispatcher(FORMULARIO).forward(request, response);
    }
}
