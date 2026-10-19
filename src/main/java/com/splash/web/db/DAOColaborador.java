package com.splash.web.db;

import com.splash.web.model.dto.ColaboradorView;
import com.splash.web.security.Passwords;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code colaborador}
 */
public class DAOColaborador {

    /*--------------------------------------
    Listagem de colaboradores
    --------------------------------------*/

    public List<ColaboradorView> listar() throws SQLException {
        String sql = "SELECT id_colaborador, nome, cargo, nivel_acesso, email "
                + "FROM colaborador ORDER BY nome";
        List<ColaboradorView> colaboradores = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                colaboradores.add(new ColaboradorView(result.getInt("id_colaborador"),
                        result.getString("nome"), result.getString("cargo"),
                        result.getString("nivel_acesso"), result.getString("email")));
            }
        }
        return colaboradores;
    }

    /**
     * Função que valida o usuário no banco.
     *
     * @param email Email do usuário no formato {@code user@domínio.com}.
     * @param senha Senha do usuário. Necessário passar senha hasheada para comparação com banco.
     * */
    public ColaboradorView autenticar(String email, String senha) throws SQLException {
        String sql = "SELECT id_colaborador, nome, cargo, nivel_acesso, email, senha_hash "
                + "FROM colaborador WHERE email = ?";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email.trim().toLowerCase());
            try (ResultSet result = statement.executeQuery()) {
                if (result.next() && Passwords.matches(senha, result.getString("senha_hash"))) {
                    return new ColaboradorView(result.getInt("id_colaborador"), result.getString("nome"),
                            result.getString("cargo"), result.getString("nivel_acesso"),
                            result.getString("email"));
                }
                return null;
            }
        }
    }

    public boolean existeAdministrador() throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection()) {
            return existeAdministrador(connection);
        }
    }

    // Recebe a conexão para rodar na mesma sessão que segura o GET_LOCK em criarAdministradorInicial
    private boolean existeAdministrador(Connection connection) throws SQLException {
        String sql = "SELECT 1 FROM colaborador WHERE nivel_acesso = 'ADMINISTRADOR' LIMIT 1";
        try (PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            return result.next();
        }
    }

    /*--------------------------------------
    Inserção de colaboradores
    --------------------------------------*/

    public void inserir(String nome, String cargo, String nivelAcesso, String email, String senha)
            throws SQLException {
        String sql = "INSERT INTO colaborador (nome, cargo, nivel_acesso, email, senha_hash) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, cargo.trim());
            statement.setString(3, nivelAcesso);
            statement.setString(4, email.trim().toLowerCase());
            statement.setString(5, Passwords.hash(senha));
            statement.executeUpdate();
        }
    }

    /**
     * Função que cria o primeiro administrador do sistema
     *
     * <p>
     *     Essa função ocorre em quatro etapas:
     *     1. É criado um {@code Lock} de 5 segundos para a realização da operação.
     *     2. É verificado se já existe um usuário ADM ativo
     *     3. É criado um usuário já com status ADMINISTRADOR
     *     4. É liberado o {@code Lock}  para outras operações
     * </p>
     *
     * @param nome Nome do administrador que será criado
     * @param cargo Cargo do administrador que será criado
     * @param email Email do administrador que será criado
     * @param senha Senha em Plaintext do administrador que será criado. Ela será hasheada automaticamente.
     *
     * */
    public void criarAdministradorInicial(String nome, String cargo, String email, String senha)
            throws SQLException {
        // Um lock é uma trava imposta para que dois usuários não realizem uma mesma operação ao mesmo tempo.
        // Com essa trava quem chegar primeiro realiza a operação em X segundos, o segundo aguarda a liberação nesse tempo.
        // Quando a operação for finalizada pelo primeiro usuário o segundo utilizará os dados atualizados

        try (Connection connection = DatabaseConnection.getConnection()) {
            try (PreparedStatement lock = connection.prepareStatement("SELECT GET_LOCK(?, 5)")) {
                lock.setString(1, "lava_rapido_initial_admin");
                try (ResultSet result = lock.executeQuery()) {
                    if (!result.next() || result.getInt(1) != 1) {
                        throw new SQLException("Não foi possível obter o bloqueio para a configuração inicial.");
                    }
                }
            }
            try {
                if (existeAdministrador(connection)) {
                    throw new IllegalStateException("A configuração inicial já foi concluída.");
                }
                String sql = "INSERT INTO colaborador (nome, cargo, nivel_acesso, email, senha_hash) "
                        + "VALUES (?, ?, 'ADMINISTRADOR', ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, nome.trim());
                    statement.setString(2, cargo.trim());
                    statement.setString(3, email.trim().toLowerCase());
                    statement.setString(4, Passwords.hash(senha));
                    statement.executeUpdate();
                }
            } finally {
                try (PreparedStatement unlock = connection.prepareStatement("SELECT RELEASE_LOCK(?)")) {
                    unlock.setString(1, "lava_rapido_initial_admin");
                    unlock.executeQuery().close();
                }
            }
        }
    }

    /*--------------------------------------
    Update de colaboradores
    --------------------------------------*/

    // Nenhuma operação de update de colaborador ainda

    /*--------------------------------------
    Remoção de colaboradores
    --------------------------------------*/

    // Nenhuma operação de remoção de colaborador ainda
}
