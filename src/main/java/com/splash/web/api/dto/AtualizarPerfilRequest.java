package com.splash.web.api.dto;

/** Corpo de {@code PATCH /api/v1/me}. Todos os campos são opcionais (null = não altera). */
public record AtualizarPerfilRequest(String nome, String telefone, String email) {
}
