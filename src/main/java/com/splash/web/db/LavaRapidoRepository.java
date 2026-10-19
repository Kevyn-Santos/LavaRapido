package com.splash.web.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.splash.web.model.dto.ClienteView;
import com.splash.web.security.Passwords;

/*Em transição: os métodos foram separados nas DAOs (ver miscelaneous/separacao-daos.md)
e os records viraram DTOs em model.dto (ver miscelaneous/dtos-criadas.md).
cadastrarCliente e autenticarCliente ficam porque ClienteRepository depende deles.*/
public final class LavaRapidoRepository {

    private LavaRapidoRepository() {
    }

    static void cadastrarCliente(String nome, String cpf, String telefone, String email, String senha)
            throws SQLException {
        String sql = "INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, cpf.trim());
            statement.setString(3, telefone.trim());
            statement.setString(4, email.trim().toLowerCase());
            statement.setString(5, Passwords.hash(senha));
            statement.executeUpdate();
        }
    }

    static ClienteView autenticarCliente(String email, String senha) throws SQLException {
        return new DAOCliente().autenticar(email, senha);
    }
}
