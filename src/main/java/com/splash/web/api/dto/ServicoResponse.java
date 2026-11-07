package com.splash.web.api.dto;

import java.math.BigDecimal;

public record ServicoResponse(int id_servico, String nome, String descricao, BigDecimal preco) {
}
