package com.splash.web.api.dto;

/** Corpo de {@code POST /api/v1/auth/login}. */
public record LoginRequest(String cpf, String senha) {
}
