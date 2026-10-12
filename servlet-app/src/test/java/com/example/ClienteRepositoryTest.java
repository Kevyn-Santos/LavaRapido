package com.example;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class ClienteRepositoryTest {

    @Test
    void deveArmazenarHashEValidarSenha() {
        String senha = "123456";
        String hash = Passwords.hash(senha);

        assertNotEquals(senha, hash);
        assertTrue(Passwords.matches(senha, hash));
        assertFalse(Passwords.matches("senhaerrada", hash));
    }
}
