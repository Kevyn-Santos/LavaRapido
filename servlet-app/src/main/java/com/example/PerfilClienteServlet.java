package com.example;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/perfil")
public class PerfilClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        try {
            LavaRapidoRepository.Cliente cliente = ClienteRepository.obterPorId(idCliente);
            if (cliente == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cliente não encontrado.");
                return;
            }
            request.setAttribute("cliente", cliente);
            request.getRequestDispatcher("/perfil.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idCliente = WebSupport.clienteId(request, response);
        if (idCliente < 0) {
            return;
        }
        String acao = WebSupport.campo(request, "acao");
        try {
            if ("atualizar".equals(acao)) {
                String nome = WebSupport.campo(request, "nome");
                String telefone = WebSupport.campo(request, "telefone");
                String email = WebSupport.campo(request, "email");
                String senhaAtual = request.getParameter("senhaAtual");
                String novaSenha = request.getParameter("novaSenha");
                if (!WebSupport.preenchidos(nome, telefone, email) || nome.length() > 100
                        || telefone.length() > 20 || email.length() > 150
                        || (novaSenha != null && !novaSenha.isBlank() && novaSenha.length() < 8)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("erro",
                            "Confira os dados do perfil. A nova senha deve ter ao menos 8 caracteres.");
                    doGet(request, response);
                    return;
                }
                if (senhaAtual == null || senhaAtual.isBlank()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("erro", "Informe sua senha atual para confirmar a alteração.");
                    doGet(request, response);
                    return;
                }
                LavaRapidoRepository.Cliente clienteAtual = ClienteRepository.obterPorId(idCliente);
                if (clienteAtual == null || LavaRapidoRepository.autenticarCliente(clienteAtual.email(), senhaAtual) == null) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    request.setAttribute("erro", "Senha atual incorreta.");
                    doGet(request, response);
                    return;
                }
                ClienteRepository.atualizar(idCliente, nome, telefone, email, novaSenha);
                request.getSession(false).setAttribute("clienteNome", nome);
                response.sendRedirect(request.getContextPath() + "/perfil?sucesso=1");
                return;
            }
            if ("excluir".equals(acao)) {
                if (ClienteRepository.possuiAgendamentoPendente(idCliente)) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    request.setAttribute("erro",
                            "Você não pode excluir a conta enquanto houver agendamentos pendentes."
                                    + " Cancele ou conclua os agendamentos antes de prosseguir.");
                    doGet(request, response);
                    return;
                }

                String senha = request.getParameter("senhaExcluir");
                if (senha == null || senha.isBlank()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("erro", "Informe a senha para confirmar a exclusão da conta.");
                    doGet(request, response);
                    return;
                }
                if (!ClienteRepository.excluir(idCliente, senha)) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    request.setAttribute("erro", "Senha incorreta. A conta não foi removida.");
                    doGet(request, response);
                    return;
                }
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                response.sendRedirect(request.getContextPath() + "/?conta=excluida");
                return;
            }
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "E-mail já cadastrado para outra conta.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }
}
