package com.splash.web.security;

import org.mindrot.jbcrypt.BCrypt;

public final class Passwords {

    private Passwords() {
    }

    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    static boolean matches(String password, String hash) {
        return hash != null && BCrypt.checkpw(password, hash);
    }
}
