package util;

import de.mkammerer.argon2.Argon2;
import de.mkammerer.argon2.Argon2Factory;

public class PasswordUtil {
    private final Argon2 argon2;

    public PasswordUtil() {
        this.argon2 = Argon2Factory.create(Argon2Factory.Argon2Types.ARGON2id);
    }

    public String hash(String password) {
        char[] chars = password.toCharArray();
        try {
            return argon2.hash(3, 65536, 2, chars);
        } finally {
            argon2.wipeArray(chars);
        }
    }

    public boolean verify(String hash, String password) {
        if (hash == null || password == null) return false;
        char[] chars = password.toCharArray();
        try {
            return argon2.verify(hash, chars);
        } finally {
            argon2.wipeArray(chars);
        }
    }
}
