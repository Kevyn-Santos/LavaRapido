package com.splash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

import com.splash.web.db.DAOCliente;

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
            "servicos", "/WEB-INF/views/painel-servicos.jsp");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String secao = pathInfo == null || pathInfo.length() < 2 ? "" : pathInfo.substring(1);
        String pagina = PAGINAS.get(secao);
        if (pagina == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (WebSupport.colaboradorId(request, response, "OPERACIONAL") < 0) {
            return;
        }

        if ("clientes".equals(secao)) {
            try {
                request.setAttribute("clientes", new DAOCliente().getUsuariosComVeiculos());
            } catch (SQLException e) {
                WebSupport.erroBanco(request, response, e);
                return;
            }
        }

        request.getRequestDispatcher(pagina).forward(request, response);
    }
}
