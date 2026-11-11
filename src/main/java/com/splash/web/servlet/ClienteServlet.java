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

@WebServlet("/clientes")
public class ClienteServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/painel-clientes.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (WebSupport.colaboradorId(request, response, "OPERACIONAL") < 0) {
            return;
        }
        try {
            DAOCliente dao = new DAOCliente();
            request.setAttribute("clientes", dao.getUsuarios());
            Integer id = WebSupport.inteiro(WebSupport.campo(request, "editar"));
            if (id != null) {
                request.setAttribute("clienteEdicao", dao.getusuario(id));
            }
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException exception) {
            if (exception instanceof SQLException sqlException) {
                WebSupport.erroBanco(request, response, sqlException);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, exception.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (WebSupport.colaboradorId(request, response, "OPERACIONAL") < 0) {
            return;
        }
        try {
            String acao = WebSupport.campo(request, "acao");
            Integer id = WebSupport.inteiro(WebSupport.campo(request, "idCliente"));
            DAOCliente dao = new DAOCliente();
            if ("remover".equals(acao)) {
                if (id == null || !dao.remover(id)) {
                    throw new IllegalArgumentException("Cliente não encontrado.");
                }
            } else if ("salvar".equals(acao)) {
                String senha = request.getParameter("senha");
                if (id == null && (senha == null || senha.length() < 8)) {
                    throw new IllegalArgumentException("A senha deve ter ao menos 8 caracteres.");
                }
                String senhaHash = senha == null || senha.isBlank() ? null : Passwords.hash(senha);
                Cliente cliente = new Cliente(WebSupport.campo(request, "nome"),
                        WebSupport.campo(request, "cpf"), WebSupport.campo(request, "telefone"),
                        WebSupport.campo(request, "email"), senhaHash == null ? "temporary" : senhaHash);
                dao.salvar(id, cliente, senhaHash);
            } else {
                throw new IllegalArgumentException("Ação de cliente inválida.");
            }
            response.sendRedirect(
                    request.getContextPath() + "/painel/clientes?sucesso=1");
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", exception.getMessage());
            doGet(request, response);
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "CPF ou e-mail já cadastrado, ou cliente possui registros vinculados.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
