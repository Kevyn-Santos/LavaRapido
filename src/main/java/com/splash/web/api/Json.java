package com.splash.web.api;

import java.io.IOException;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Helper central de JSON da API {@code /api/v1/*}: escreve respostas ({@code application/json},
 * UTF-8), o formato de erro padrão {@code {"erro": "mensagem"}}, lê o corpo da requisição e trata
 * campos nulos. Registro: miscelaneous/api-json-requisicao-resposta-erros.md.
 */
public final class Json {

    private Json() {
    }

    /** Escreve {@code corpo} (texto JSON) com status 200. */
    public static void Response_ok(HttpServletResponse response, Object corpo) throws IOException {
        response.setContentType("application/json"); // Define a resposta como Json
        response.setCharacterEncoding("UTF-8"); // Define a codificação de texto em UTF-8
        response.setStatus(HttpServletResponse.SC_OK); // Define o código HTTP informado
        response.getWriter().print(corpo);
    }

    /** Escreve {@code corpo} (texto JSON) com o status informado (ex.: 201 ao criar). */
    public static void Response_enviar(HttpServletResponse response, int status, Object corpo) throws IOException {
        response.setContentType("application/json"); // Define a resposta como Json
        response.setCharacterEncoding("UTF-8"); // Define a codificação de texto em UTF-8
        response.setStatus(status); // Define o código HTTP informado
        response.getWriter().print(corpo);
    }

    /** Escreve {@code {"erro": "mensagem"}} (JSON válido) com o status informado. */
    public static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        Response_enviar(response, status, new JSONObject().put("erro", mensagem).toString());
    }

    /**
     * Lê o corpo da requisição como um objeto JSON.
     *
     * @throws JSONException se o corpo estiver vazio ou não for um objeto JSON válido (os servlets
     *                       respondem 400 nesse caso)
     */
    public static JSONObject lerCorpo(HttpServletRequest request) throws IOException {
        String corpo = request.getReader().lines().collect(Collectors.joining());
        if (corpo.isBlank()) {
            throw new JSONException("Corpo da requisição vazio");
        }
        return new JSONObject(corpo);
    }

    /**
     * Valor pronto para {@link JSONObject#put(String, Object)}: {@code put(chave, null)} remove a
     * chave, então {@code null} vira {@link JSONObject#NULL} para o campo continuar no JSON.
     */
    public static Object ouNulo(Object valor) {
        return valor == null ? JSONObject.NULL : valor;
    }
}
