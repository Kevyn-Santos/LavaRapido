package com.example;

import org.mindrot.jbcrypt.BCrypt;

final class Passwords {

    private Passwords() {
    }

    static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    static boolean matches(String password, String hash) {
        return hash != null && BCrypt.checkpw(password, hash);
    }
}
