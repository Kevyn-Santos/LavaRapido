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

/**
 * Valida o header {@code Authorization: Bearer <token>} em todas as rotas de {@code /api/v1/*},
 * exceto {@code /api/v1/auth/*} e {@code GET /api/v1/servicos}, e expõe o id do cliente
 * autenticado via {@code request.setAttribute("idCliente", ...)}.
 *
 * TODO: validar o token com {@link com.splash.web.api.jwt.JwtService}, deixar passar as rotas
 * públicas e responder 401 (via {@link Json#erro}) quando o token faltar ou for inválido.
 * Ver miscelaneous/analise-app-mobile.md, seção 3.4.
 */
@WebFilter("/api/v1/*")
public class ApiAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        // TODO: implementar a validação do token antes de liberar a cadeia.
        chain.doFilter(httpRequest, httpResponse);
    }
}
