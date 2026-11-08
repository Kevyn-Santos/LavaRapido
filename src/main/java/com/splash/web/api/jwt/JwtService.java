package com.splash.web.api.jwt;

/**
 * Geração e validação dos tokens JWT usados pela API (autenticação stateless, sem HttpSession).
 *
 * TODO: implementar com java-jwt (com.auth0), assinatura HMAC e segredo lido de JWT_SECRET
 * (variável de ambiente / dotenv-java, como o DatabaseConnection já faz).
 * Requer adicionar a dependência java-jwt ao pom.xml
 * (ver miscelaneous/analise-app-mobile.md, seções 3.3 e 3.4).
 */
public final class JwtService {

    private JwtService() {
    }

    /** Gera um token para o cliente autenticado, com expiração de algumas horas. */
    public static String gerar(int idCliente) {
        // TODO
        return null;
    }

    /** Valida o token e devolve o id do cliente (claim {@code sub}), ou -1 se inválido/expirado. */
    public static int validar(String token) {
        // TODO
        return -1;
    }
}
