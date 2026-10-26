package com.splash.web.api.dto;

/** Dados do cliente devolvidos pela API (login e {@code GET /api/v1/me}). */
public record ClienteResumo(int id, String nome, String cpf, String telefone, String email) {
}
