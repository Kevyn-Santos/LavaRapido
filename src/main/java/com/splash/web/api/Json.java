package com.splash.web.api;

import java.io.IOException;
import java.lang.reflect.Array;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Helper central de serialização JSON da API. Foramtações constanxtes de resposta, corretas ou com erros, podem ser feitos por aqui, por exemplo:
 * <p> Header de resposta pode ser definido como {@code application/json; charset=UTF-8}</p>
 * <p>Erros podem ser formatados como {@code { "erro": "mensagem" } }.</p>
 * <p>Writter pode ser definido com {@code response.getWriter().print()}</p>
 * (ver miscelaneous/analise-app-mobile.md, seção 3.3).
 */
public final class Json {

    private Json() {
    }

    /** Escreve {@code corpo} serializado em JSON com status 200. */
    public static void Response_ok(HttpServletResponse response, Object corpo) throws IOException {
        response.setContentType("application/json"); // Define a resposta como Json
        response.setCharacterEncoding("UTF-8"); // Define a codificação de texto em UTF-8
        response.setStatus(HttpServletResponse.SC_OK); // Define código HTTP 200 com o padrão da página
        response.getWriter().print(corpo);
    }

    /** Escreve {@code corpo} serializado em JSON com o status informado (ex.: 201 ao criar). */
    public static void Response_enviar(HttpServletResponse response, int status, Object corpo) throws IOException {
        response.setContentType("application/json"); // Define a resposta como Json
        response.setCharacterEncoding("UTF-8"); // Define a codificação de texto em UTF-8
        response.setStatus(status); // Define código HTTP 200 com o padrão da página
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
     * Lê um parâmetro inteiro da query string (ex.: {@code ?idcliente=1}).
     *
     * @throws IllegalArgumentException se o parâmetro faltar ou não for um inteiro
     */
    public static int parametroInt(HttpServletRequest request, String nome) {
        String valor = request.getParameter(nome);
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Parâmetro '" + nome + "' ausente ou inválido");
        }
    }

    /**
     * Valor pronto para {@link JSONObject#put(String, Object)}: {@code put(chave, null)} remove a
     * chave, então {@code null} vira {@link JSONObject#NULL} para o campo continuar no JSON.
     */
    public static Object ouNulo(Object valor) {
        return valor == null ? JSONObject.NULL : valor;
    }

    /** Lê e desserializa o corpo da requisição para o tipo informado. */
    public static <T> T ler(HttpServletRequest request, Class<T> tipo) throws IOException {
        // TODO
        return null;
    }
}
