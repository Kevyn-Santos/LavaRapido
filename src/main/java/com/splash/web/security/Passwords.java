package com.splash.web.security;

import org.mindrot.jbcrypt.BCrypt;

public final class Passwords {

    private Passwords() {
    }

    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    /**
     * Confere a senha contra o hash BCrypt. Devolve {@code false} (e não lança exceção) quando a senha
     * ou o hash são nulos ou quando o hash guardado não é um BCrypt válido: um dado ruim no banco
     * significa "senha não confere", nunca erro 500 no login. Hashes com prefixo {@code $2y$} ou
     * {@code $2b$} (mesmo algoritmo do {@code $2a$}, gerados por outras ferramentas) são aceitos.
     */
    public static boolean matches(String password, String hash) {
        if (password == null || hash == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(password, normalizarPrefixo(hash));
        } catch (IllegalArgumentException | StringIndexOutOfBoundsException hashInvalido) {
            // jBCrypt: IllegalArgumentException para prefixo/custo inválido; StringIndexOutOfBounds para hash vazio ou curto
            return false;
        }
    }

    private static String normalizarPrefixo(String hash) {
        if (hash.startsWith("$2y$") || hash.startsWith("$2b$")) {
            return "$2a$" + hash.substring(4);
        }
        return hash;
    }
}
