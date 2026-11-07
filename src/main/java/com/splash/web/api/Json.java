package com.splash.web.api;

import java.io.IOException;
import java.lang.reflect.Array;
import java.util.List;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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

    /** Escreve {@code { "erro": mensagem } } com o status informado. */
    public static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        String erroJson= """
                "Erro": %s
                """.formatted(mensagem);

        Response_enviar(response, status, erroJson);
    }

    /** Lê e desserializa o corpo da requisição para o tipo informado. */
    public static <T> T ler(HttpServletRequest request, Class<T> tipo) throws IOException {
        // TODO
        return null;
    }
}
