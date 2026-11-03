package com.splash.web.servlet;

import java.io.IOException;
import java.util.Map;

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
        request.getRequestDispatcher(pagina).forward(request, response);
    }
}
