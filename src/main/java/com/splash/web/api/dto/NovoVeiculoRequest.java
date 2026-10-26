package com.splash.web.api.dto;

/** Corpo de {@code POST /api/v1/veiculos}. */
public record NovoVeiculoRequest(String placa, String marca, String modelo, String cor) {
}
