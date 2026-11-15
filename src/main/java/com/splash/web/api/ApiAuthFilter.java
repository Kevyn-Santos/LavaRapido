package com.splash.web.api;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Porteiro de {@code /api/v1/*}: exige que o cliente tenha feito login (sessão {@code HttpSession}
 * com o atributo {@code clienteId}, o mesmo usado pelo site web).
 *
 * <p>Rotas públicas: {@code /api/v1/auth/*} (login) e {@code GET /api/v1/servicos}. Nas demais,
 * sem sessão válida a resposta é 401 {@code {"erro": "..."}}; com sessão, o id do cliente fica em
 * {@code request.setAttribute("idCliente", ...)} e os servlets o leem por {@link #idAutenticado}.
 * Por isso o cliente nunca informa o próprio id na URL ou no corpo: ele vem do servidor.
 *
 * <p>Registro: miscelaneous/autenticacao-sessao-api-mobile.md.
 */
@WebFilter("/api/v1/*")
public class ApiAuthFilter implements Filter {

    /** Mesma chave de sessão que {@code LoginServlet}/{@code WebSupport} usam no site web. */
    public static final String SESSAO_CLIENTE_ID = "clienteId";

    private static final String ATRIBUTO_REQUEST = "idCliente";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (rotaPublica(httpRequest)) {
            chain.doFilter(httpRequest, httpResponse);
            return;
        }

        HttpSession sessao = httpRequest.getSession(false); // false: não cria sessão para quem não logou
        Object id = sessao == null ? null : sessao.getAttribute(SESSAO_CLIENTE_ID);
        if (!(id instanceof Integer idCliente)) {
            Json.erro(httpResponse, HttpServletResponse.SC_UNAUTHORIZED, "Faça login para continuar");
            return;
        }

        httpRequest.setAttribute(ATRIBUTO_REQUEST, idCliente);
        chain.doFilter(httpRequest, httpResponse);
    }

    /** Id do cliente logado. Só vale em rotas protegidas, onde o filtro já garantiu a sessão. */
    public static int idAutenticado(HttpServletRequest request) {
        return (Integer) request.getAttribute(ATRIBUTO_REQUEST);
    }

    private static boolean rotaPublica(HttpServletRequest request) {
        String caminho = request.getRequestURI().substring(request.getContextPath().length());
        return caminho.startsWith("/api/v1/auth/")
                || ("GET".equals(request.getMethod()) && "/api/v1/servicos".equals(caminho));
    }
}
