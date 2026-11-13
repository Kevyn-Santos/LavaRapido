
package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

import com.splash.web.db.DAOCliente;
import com.splash.web.db.DAOAtendimento;
import com.splash.web.db.DAOPagamento;
import com.splash.web.db.DAOColaborador;
import com.splash.web.db.DAOServico;
import com.splash.web.db.DAOAgendamento;
import com.splash.web.db.DAOHistorico;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/painel/*")
public class PainelServlet extends HttpServlet {

    private static final Map<String, String> PAGINAS = Map.of(
            "clientes", "/WEB-INF/views/painel-clientes.jsp",
            "carros", "/WEB-INF/views/painel-carros.jsp",
            "agendamentos", "/WEB-INF/views/painel-agendamentos.jsp",
            "atendimentos", "/WEB-INF/views/painel-atendimentos.jsp",
            "pagamentos", "/WEB-INF/views/painel-pagamentos.jsp",
            "colaboradores", "/WEB-INF/views/painel-colaboradores.jsp",
            "servicos", "/WEB-INF/views/painel-servicos.jsp",
            "historico", "/WEB-INF/views/painel-historico.jsp");

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        String secao = pathInfo == null || pathInfo.length() < 2
                ? ""
                : pathInfo.substring(1);

        String pagina = PAGINAS.get(secao);

        if (pagina == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String nivelNecessario = switch (secao) {
            case "servicos", "colaboradores" -> "ADMINISTRADOR";
            case "pagamentos" -> "ATENDENTE";
            default -> "OPERACIONAL";
        };

        if (WebSupport.colaboradorId(
                request, response, nivelNecessario) < 0) {
            return;
        }

        try {
            switch (secao) {

                case "clientes" -> {
                    request.setAttribute(
                            "clientes",
                            new DAOCliente().getUsuariosComVeiculos());
                }

                case "carros" -> {
                    request.setAttribute(
                            "clientes",
                            new DAOCliente().getUsuariosComVeiculos());
                }

                case "agendamentos" -> {

                    request.setAttribute(
                            "agendamentos",
                            new DAOAgendamento().listarTodos());

                    request.setAttribute(
                            "clientes",
                            new DAOCliente().getUsuariosComVeiculos());

                    request.setAttribute(
                            "servicos",
                            new DAOServico().listar());
                }

                case "atendimentos" -> {
                    request.setAttribute(
                            "atendimentos",
                            new DAOAtendimento().listar());

                    request.setAttribute(
                            "colaboradores",
                            new DAOColaborador().listar());
                }

                case "pagamentos" -> {
                    request.setAttribute(
                            "pagamentos",
                            new DAOPagamento().listar());
                }

                case "colaboradores" -> {
                    request.setAttribute(
                            "colaboradores",
                            new DAOColaborador().listar());
                }

                case "servicos" -> {
                    request.setAttribute(
                            "servicos",
                            new DAOServico().listar());
                }

                default -> {
                    // Carros e agendamentos serão
                    // integrados nas próximas etapas.
                }

                case "historico" -> {

                    DAOHistorico daoHistorico = new DAOHistorico();

                    String pesquisa = request.getParameter("pesquisa");
                    String parametroId = request.getParameter("idCliente");

                    request.setAttribute("pesquisa", pesquisa);

                    // Pesquisa por nome ou ID
                    request.setAttribute(
                            "clientesHistorico",
                            daoHistorico.pesquisarClientes(pesquisa));

                    // Histórico detalhado do cliente selecionado
                    if (parametroId != null && !parametroId.isBlank()) {

                        Integer idCliente = WebSupport.inteiro(parametroId);

                        if (idCliente == null || idCliente <= 0) {
                            throw new IllegalArgumentException(
                                    "ID do cliente inválido.");
                        }

                        request.setAttribute("idClienteSelecionado", idCliente);

                        request.setAttribute(
                                "registrosHistorico",
                                daoHistorico.listarHistoricoCliente(idCliente));
                    }
                }

            }

            request.getRequestDispatcher(pagina)
                    .forward(request, response);

        } catch (SQLException exception) {
            WebSupport.erroBanco(
                    request, response, exception);
        }
    }
}
