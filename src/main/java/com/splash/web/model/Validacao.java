package com.splash.web.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.regex.Pattern;

/**
 * Regras de validação reutilizadas pelas entidades do modelo.
 * Todas lançam IllegalArgumentException quando o dado é inválido
 * e devolvem o valor já normalizado.
 */
final class Validacao {

    private static final Pattern EMAIL = Pattern.compile("^[\\w.%+-]+@[\\w-]+(\\.[\\w-]+)+$");
    // Padrão antigo (ABC1234) e Mercosul (ABC1D23)
    private static final Pattern PLACA = Pattern.compile("^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$");

    private Validacao() {
    }

    static <T> T obrigatorio(T valor, String campo) {
        if (valor == null) {
            throw new IllegalArgumentException(campo + " é obrigatório.");
        }
        return valor;
    }

    static String textoObrigatorio(String valor, String campo, int max) {
        if (valor == null || valor.isBlank()) {
            throw new IllegalArgumentException(campo + " é obrigatório.");
        }
        String limpo = valor.trim();
        if (limpo.length() > max) {
            throw new IllegalArgumentException(campo + " deve ter no máximo " + max + " caracteres.");
        }
        return limpo;
    }

    static String textoOpcional(String valor, String campo, int max) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return textoObrigatorio(valor, campo, max);
    }

    static String email(String valor) {
        String limpo = textoObrigatorio(valor, "E-mail", 150).toLowerCase();
        if (!EMAIL.matcher(limpo).matches()) {
            throw new IllegalArgumentException("E-mail inválido.");
        }
        return limpo;
    }

    /** Valida apenas o formato (11 dígitos) e devolve só os números. */
    static String cpf(String valor) {
        String digitos = somenteDigitos(valor);
        if (digitos.length() != 11) {
            throw new IllegalArgumentException("CPF deve ter 11 dígitos.");
        }
        return digitos;
    }

    static String telefone(String valor) {
        String digitos = somenteDigitos(valor);
        if (digitos.length() < 10 || digitos.length() > 11) {
            throw new IllegalArgumentException("Telefone deve ter 10 ou 11 dígitos (DDD + número).");
        }
        return digitos;
    }

    static String placa(String valor) {
        String limpa = textoObrigatorio(valor, "Placa", 10).replace("-", "").toUpperCase();
        if (!PLACA.matcher(limpa).matches()) {
            throw new IllegalArgumentException("Placa inválida.");
        }
        return limpa;
    }

    static BigDecimal valorMonetario(BigDecimal valor, String campo) {
        obrigatorio(valor, campo);
        if (valor.signum() < 0) {
            throw new IllegalArgumentException(campo + " não pode ser negativo.");
        }
        return valor.setScale(2, RoundingMode.HALF_UP);
    }

    private static String somenteDigitos(String valor) {
        return valor == null ? "" : valor.replaceAll("\\D", "");
    }
}
