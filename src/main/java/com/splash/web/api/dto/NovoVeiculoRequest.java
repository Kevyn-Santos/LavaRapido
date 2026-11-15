package com.splash.web.api.dto;

/**
 * Dados de {@code POST /api/v1/veiculos}. O campo {@code id} é o id do <b>cliente dono</b> (vem da sessão,
 * não do corpo); {@code cor} é opcional (null/vazia grava NULL).
 */
public record NovoVeiculoRequest(int id, String placa, String marca, String modelo, String cor) {
}
