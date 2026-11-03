package com.splash.web.api.dto;

/** Corpo de {@code POST /api/v1/veiculos}. */
public record NovoVeiculoRequest(int id, String placa, String marca, String modelo, String cor) {
}
