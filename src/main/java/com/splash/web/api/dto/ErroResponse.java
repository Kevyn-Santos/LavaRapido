package com.splash.web.api.dto;

/** Formato padrão de erro da API: {@code { "erro": "mensagem" } }. */
public record ErroResponse(String erro) {
}
