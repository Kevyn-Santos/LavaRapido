package com.example;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    private static final Set<String> STATUS_ATENDIMENTO =
            Set.of("AGUARDANDO", "EM_LAVAGEM", "FINALIZADO", "ENTREGUE");
    private static final Set<String> FORMAS_PAGAMENTO =
            Set.of("DINHEIRO", "PIX", "CREDITO", "DEBITO");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String secao = secao(request);
        String nivel = nivelNecessario(secao);
        if (nivel == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (WebSupport.colaboradorId(request, response, nivel) < 0) {
            return;
        }
        try {
            request.setAttribute("secao", secao);
            switch (secao) {
                case "servicos" -> request.setAttribute("servicos", LavaRapidoRepository.listarServicos());
                case "colaboradores" ->
                    request.setAttribute("colaboradores", LavaRapidoRepository.listarColaboradores());
                case "atendimentos" -> {
                    request.setAttribute("atendimentos", LavaRapidoRepository.listarAtendimentos());
                    request.setAttribute("colaboradores", LavaRapidoRepository.listarColaboradores());
                }
                case "pagamentos" -> request.setAttribute("pagamentos", LavaRapidoRepository.listarPagamentos());
                default -> {
                }
            }
            request.getRequestDispatcher("/admin.jsp").forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String secao = secao(request);
        String nivel = nivelNecessario(secao);
        if (nivel == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (WebSupport.colaboradorId(request, response, nivel) < 0) {
            return;
        }
        try {
            switch (secao) {
                case "servicos" -> processarServico(request);
                case "colaboradores" -> processarColaborador(request);
                case "atendimentos" -> processarAtendimento(request);
                case "pagamentos" -> processarPagamento(request);
                default -> {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/" + secao + "?sucesso=1");
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", exception.getMessage());
            doGet(request, response);
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "A operação viola uma restrição de dados (e-mail duplicado ou registro em uso).");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }

    private void processarServico(HttpServletRequest request) throws SQLException {
        String acao = WebSupport.campo(request, "acao");
        Integer id = WebSupport.inteiro(WebSupport.campo(request, "idServico"));
        if ("remover".equals(acao)) {
            if (id == null || !LavaRapidoRepository.removerServico(id)) {
                throw new IllegalArgumentException("Serviço não encontrado.");
            }
            return;
        }
        if (!"salvar".equals(acao)) {
            throw new IllegalArgumentException("Ação de serviço inválida.");
        }
        String nome = WebSupport.campo(request, "nome");
        String descricao = WebSupport.campo(request, "descricao");
        BigDecimal preco;
        try {
            preco = new BigDecimal(WebSupport.campo(request, "preco").replace(',', '.'));
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Informe um preço válido.");
        }
        if (!WebSupport.preenchidos(nome) || nome.length() > 100 || descricao.length() > 255
                || preco.signum() < 0 || preco.precision() > 10 || preco.scale() > 2) {
            throw new IllegalArgumentException("Confira nome, descrição e preço (máximo 2 casas decimais).");
        }
        LavaRapidoRepository.salvarServico(id, nome, descricao, preco);
    }

    private void processarColaborador(HttpServletRequest request) throws SQLException {
        String acao = WebSupport.campo(request, "acao");
        Integer id = WebSupport.inteiro(WebSupport.campo(request, "idColaborador"));
        if ("remover".equals(acao)) {
            if (id == null || !LavaRapidoRepository.removerColaborador(id)) {
                throw new IllegalArgumentException("Colaborador não encontrado.");
            }
            return;
        }
        if (!"salvar".equals(acao)) {
            throw new IllegalArgumentException("Ação de colaborador inválida.");
        }
        String nome = WebSupport.campo(request, "nome");
        String cargo = WebSupport.campo(request, "cargo");
        String email = WebSupport.campo(request, "email");
        String senha = request.getParameter("senha");
        String nivel = WebSupport.campo(request, "nivelAcesso");
        boolean atualizar = id != null;
        if (!WebSupport.preenchidos(nome, cargo, email) || nome.length() > 100 || cargo.length() > 60
                || email.length() > 150 || !Set.of("ADMINISTRADOR", "ATENDENTE", "OPERACIONAL").contains(nivel)
                || (!atualizar && (senha == null || senha.isBlank() || senha.length() < 8))) {
            throw new IllegalArgumentException(
                    atualizar ? "Confira os dados do colaborador." : "Confira os dados do colaborador; a senha deve ter ao menos 8 caracteres.");
        }
        if (atualizar && senha != null && !senha.isBlank() && senha.length() < 8) {
            throw new IllegalArgumentException("A senha nova deve ter ao menos 8 caracteres.");
        }
        LavaRapidoRepository.salvarColaborador(id, nome, cargo, nivel, email, senha);
    }

    private void processarAtendimento(HttpServletRequest request) throws SQLException {
        Integer id = WebSupport.inteiro(WebSupport.campo(request, "idAtendimento"));
        String status = WebSupport.campo(request, "status");
        if (id == null || !STATUS_ATENDIMENTO.contains(status)) {
            throw new IllegalArgumentException("Atendimento ou status inválido.");
        }
        List<Integer> ids = new ArrayList<>();
        String[] recebidos = request.getParameterValues("idColaboradores");
        if (recebidos != null) {
            for (String recebido : recebidos) {
                Integer colaboradorId = WebSupport.inteiro(recebido);
                if (colaboradorId == null || colaboradorId <= 0) {
                    throw new IllegalArgumentException("A lista de colaboradores contém um item inválido.");
                }
                ids.add(colaboradorId);
            }
        }
        LavaRapidoRepository.atualizarAtendimento(id, status, ids);
    }

    private void processarPagamento(HttpServletRequest request) throws SQLException {
        Integer id = WebSupport.inteiro(WebSupport.campo(request, "idPagamento"));
        String status = WebSupport.campo(request, "status");
        String forma = WebSupport.campo(request, "formaPagamento");
        if (id == null || !Set.of("PAGO", "CANCELADO").contains(status)
                || ("PAGO".equals(status) && !FORMAS_PAGAMENTO.contains(forma))) {
            throw new IllegalArgumentException("Selecione um pagamento, status e forma válidos.");
        }
        LavaRapidoRepository.atualizarPagamento(id, status, forma);
    }

    private String secao(HttpServletRequest request) {
        String path = request.getPathInfo();
        return path == null || "/".equals(path) ? "inicio" : path.substring(1);
    }

    private String nivelNecessario(String secao) {
        return switch (secao) {
            case "inicio", "atendimentos" -> "OPERACIONAL";
            case "pagamentos" -> "ATENDENTE";
            case "servicos", "colaboradores" -> "ADMINISTRADOR";
            default -> null;
        };
    }
}
