package com.splash.web.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;

import com.splash.web.db.DAOServico;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/servicos")
public class ServicoServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/painel-servicos.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (WebSupport.colaboradorId(request, response, "ADMINISTRADOR") < 0) {
            return;
        }
        try {
            DAOServico dao = new DAOServico();
            request.setAttribute("servicos", dao.listar());
            Integer id = WebSupport.inteiro(WebSupport.campo(request, "editar"));
            if (id != null) {
                request.setAttribute("servicoEdicao", dao.buscar(id));
            }
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException exception) {
            WebSupport.erroBanco(request, response, exception);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (WebSupport.colaboradorId(request, response, "ADMINISTRADOR") < 0) {
            return;
        }
        try {
            String acao = WebSupport.campo(request, "acao");
            Integer id = WebSupport.inteiro(WebSupport.campo(request, "idServico"));
            DAOServico dao = new DAOServico();
            if ("remover".equals(acao)) {
                if (id == null || !dao.remover(id)) {
                    throw new IllegalArgumentException("Serviço não encontrado.");
                }
            } else if ("salvar".equals(acao)) {
                BigDecimal preco = parsePreco(WebSupport.campo(request, "preco"));
                String nome = WebSupport.campo(request, "nome");
                String descricao = WebSupport.campo(request, "descricao");
                if (!WebSupport.preenchidos(nome) || nome.length() > 100 || descricao.length() > 255
                        || preco.signum() < 0 || preco.scale() > 2 || preco.precision() > 10) {
                    throw new IllegalArgumentException("Confira nome, descrição e preço.");
                }
                dao.salvar(id, nome, descricao, preco);
            } else {
                throw new IllegalArgumentException("Ação de serviço inválida.");
            }
            response.sendRedirect(request.getContextPath() + "/servicos?sucesso=1");
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("erro", exception.getMessage());
            doGet(request, response);
        } catch (SQLException exception) {
            if (exception.getSQLState() != null && exception.getSQLState().startsWith("23")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                request.setAttribute("erro", "O serviço está sendo usado ou viola uma restrição de dados.");
                doGet(request, response);
                return;
            }
            WebSupport.erroBanco(request, response, exception);
        }
    }

    private BigDecimal parsePreco(String valor) {
        try {
            return new BigDecimal(valor.replace(',', '.')).setScale(2, RoundingMode.UNNECESSARY);
        } catch (NumberFormatException | ArithmeticException exception) {
            throw new IllegalArgumentException("Informe um preço válido.");
        }
    }
}
