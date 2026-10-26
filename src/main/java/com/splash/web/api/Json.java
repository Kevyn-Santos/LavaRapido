package com.splash.web.api;

import java.io.IOException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Helper central de serialização JSON da API. Deve escrever sempre
 * {@code application/json; charset=UTF-8} e formatar erros como {@code { "erro": "mensagem" } }.
 *
 * TODO: implementar com um {@code ObjectMapper} único (Jackson + JavaTimeModule).
 * Requer adicionar jackson-databind e jackson-datatype-jsr310 ao pom.xml
 * (ver miscelaneous/analise-app-mobile.md, seção 3.3).
 */
public final class Json {

    private Json() {
    }

    /** Escreve {@code corpo} serializado em JSON com status 200. */
    public static void ok(HttpServletResponse response, Object corpo) throws IOException {
        // TODO
    }

    /** Escreve {@code corpo} serializado em JSON com o status informado (ex.: 201 ao criar). */
    public static void ok(HttpServletResponse response, int status, Object corpo) throws IOException {
        // TODO
    }

    /** Escreve {@code { "erro": mensagem } } com o status informado. */
    public static void erro(HttpServletResponse response, int status, String mensagem) throws IOException {
        // TODO
    }

    /** Lê e desserializa o corpo da requisição para o tipo informado. */
    public static <T> T ler(HttpServletRequest request, Class<T> tipo) throws IOException {
        // TODO
        return null;
    }
}
