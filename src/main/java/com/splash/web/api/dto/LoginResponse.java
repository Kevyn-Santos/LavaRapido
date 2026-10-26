package com.splash.web.api.dto;

/** Resposta de {@code POST /api/v1/auth/login}. */
public record LoginResponse(String token, ClienteResumo cliente) {
}
