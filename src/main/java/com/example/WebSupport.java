package com.example;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

final class WebSupport {

    private WebSupport() {
    }

    static int clienteId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Object id = sessionValue(request, "clienteId");
        if (id instanceof Integer clienteId) {
            return clienteId;
        }
        response.sendRedirect(request.getContextPath() + "/login");
        return -1;
    }

    static int colaboradorId(HttpServletRequest request, HttpServletResponse response, String nivelMinimo)
            throws IOException {
        Object id = sessionValue(request, "colaboradorId");
        Object nivel = sessionValue(request, "nivelAcesso");
        if (id instanceof Integer colaboradorId && nivel instanceof String nivelAcesso
                && nivel(nivelAcesso) >= nivel(nivelMinimo)) {
            return colaboradorId;
        }
        if (id instanceof Integer) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Seu perfil não permite esta operação.");
        } else {
            response.sendRedirect(request.getContextPath() + "/colaborador/login");
        }
        return -1;
    }

    static void erroBanco(HttpServletRequest request, HttpServletResponse response,
            SQLException exception) throws ServletException, IOException {
        request.setAttribute("mensagem", "Não foi possível concluir a operação. Verifique a conexão e os dados do banco.");
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        request.getServletContext().log("Falha ao acessar o banco de dados.", exception);
        request.getRequestDispatcher("/erro.jsp").forward(request, response);
    }

    static String campo(HttpServletRequest request, String nome) {
        String valor = request.getParameter(nome);
        return valor == null ? "" : valor.trim();
    }

    static Integer inteiro(String valor) {
        try {
            return Integer.valueOf(valor);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    static boolean preenchidos(String... valores) {
        for (String valor : valores) {
            if (valor == null || valor.isBlank()) {
                return false;
            }
        }
        return true;
    }

    private static Object sessionValue(HttpServletRequest request, String key) {
        HttpSession session = request.getSession(false);
        return session == null ? null : session.getAttribute(key);
    }

    private static int nivel(String valor) {
        return switch (valor) {
            case "ADMINISTRADOR" -> 3;
            case "ATENDENTE" -> 2;
            case "OPERACIONAL" -> 1;
            default -> 0;
        };
    }
}
