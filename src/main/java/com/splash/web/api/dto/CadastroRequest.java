package com.splash.web.api.dto;

/** Corpo de {@code POST /api/v1/auth/cadastro}. */
public record CadastroRequest(String nome, String cpf, String telefone, String email, String senha) {
}
