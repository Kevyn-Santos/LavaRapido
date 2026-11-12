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
        String sql = """
                SELECT id_colaborador, nome, cargo, nivel_acesso, email
                FROM colaborador
                WHERE ativo = TRUE
                ORDER BY id_colaborador DESC
                """;
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
     * @param senha Senha do usuário. Necessário passar senha hasheada para
     *              comparação com banco.
     */
    public ColaboradorView autenticar(String email, String senha) throws SQLException {
        String sql = """
                SELECT id_colaborador, nome, cargo, nivel_acesso, email, senha_hash
                FROM colaborador
                WHERE email = ?
                  AND ativo = TRUE
                """;
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

    // Recebe a conexão para rodar na mesma sessão que segura o GET_LOCK em
    // criarAdministradorInicial
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
     * Essa função ocorre em quatro etapas:
     * 1. É criado um {@code Lock} de 5 segundos para a realização da operação.
     * 2. É verificado se já existe um usuário ADM ativo
     * 3. É criado um usuário já com status ADMINISTRADOR
     * 4. É liberado o {@code Lock} para outras operações
     * </p>
     *
     * @param nome  Nome do administrador que será criado
     * @param cargo Cargo do administrador que será criado
     * @param email Email do administrador que será criado
     * @param senha Senha em Plaintext do administrador que será criado. Ela será
     *              hasheada automaticamente.
     *
     */
    public void criarAdministradorInicial(String nome, String cargo, String email, String senha)
            throws SQLException {
        // Um lock é uma trava imposta para que dois usuários não realizem uma mesma
        // operação ao mesmo tempo.
        // Com essa trava quem chegar primeiro realiza a operação em X segundos, o
        // segundo aguarda a liberação nesse tempo.
        // Quando a operação for finalizada pelo primeiro usuário o segundo utilizará os
        // dados atualizados

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

    public void atualizar(int idColaborador, String nome, String cargo,
            String nivelAcesso, String email, String senha)
            throws SQLException {

        if (idColaborador <= 0) {
            throw new IllegalArgumentException(
                    "ID do colaborador inválido.");
        }

        List<String> colunas = new ArrayList<>();
        List<String> valores = new ArrayList<>();

        if (nome != null && !nome.isBlank()) {
            colunas.add("nome = ?");
            valores.add(nome.trim());
        }

        if (cargo != null && !cargo.isBlank()) {
            colunas.add("cargo = ?");
            valores.add(cargo.trim());
        }

        if (nivelAcesso != null && !nivelAcesso.isBlank()) {
            if (!java.util.Set.of(
                    "ADMINISTRADOR",
                    "ATENDENTE",
                    "OPERACIONAL").contains(nivelAcesso)) {
                throw new IllegalArgumentException(
                        "Nível de acesso inválido.");
            }

            colunas.add("nivel_acesso = ?");
            valores.add(nivelAcesso);
        }

        if (email != null && !email.isBlank()) {
            colunas.add("email = ?");
            valores.add(email.trim().toLowerCase());
        }

        // A senha só será modificada se uma nova for informada.
        if (senha != null && !senha.isBlank()) {
            if (senha.length() < 8) {
                throw new IllegalArgumentException(
                        "A senha deve ter ao menos 8 caracteres.");
            }

            colunas.add("senha_hash = ?");
            valores.add(Passwords.hash(senha));
        }

        if (colunas.isEmpty()) {
            throw new IllegalArgumentException(
                    "Informe ao menos um campo para atualizar.");
        }

        String sql = "UPDATE colaborador SET "
                + String.join(", ", colunas)
                + " WHERE id_colaborador = ?";

        try (Connection connection = DatabaseConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {

            int indice = 1;

            for (String valor : valores) {
                statement.setString(indice++, valor);
            }

            statement.setInt(indice, idColaborador);

            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException(
                        "Colaborador não encontrado ou nenhuma linha alterada.");
            }
        }
    }

    // Nenhuma operação de update de colaborador ainda

    /*--------------------------------------
    Remoção de colaboradores
    --------------------------------------*/

    public boolean remover(int idColaborador) throws SQLException {

        if (idColaborador <= 0) {
            throw new IllegalArgumentException(
                    "ID do colaborador inválido.");
        }

        try (Connection connection = DatabaseConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {
                // Bloqueia os administradores ativos durante a operação.
                int totalAdministradores = 0;

                String consultarAdministradores = """
                        SELECT id_colaborador
                        FROM colaborador
                        WHERE nivel_acesso = 'ADMINISTRADOR'
                          AND ativo = TRUE
                        FOR UPDATE
                        """;

                try (PreparedStatement statement = connection.prepareStatement(consultarAdministradores);
                        ResultSet result = statement.executeQuery()) {

                    while (result.next()) {
                        totalAdministradores++;
                    }
                }

                // Consulta o colaborador que será removido.
                String consultar = """
                        SELECT nivel_acesso
                        FROM colaborador
                        WHERE id_colaborador = ?
                          AND ativo = TRUE
                        FOR UPDATE
                        """;

                String nivelAcesso;

                try (PreparedStatement statement = connection.prepareStatement(consultar)) {

                    statement.setInt(1, idColaborador);

                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException(
                                    "Colaborador não encontrado ou inativo.");
                        }

                        nivelAcesso = result.getString("nivel_acesso");
                    }
                }

                if ("ADMINISTRADOR".equals(nivelAcesso)
                        && totalAdministradores <= 1) {
                    throw new IllegalArgumentException(
                            "Não é possível remover o último administrador ativo.");
                }

                // Exclusão lógica: mantém o registro e seus vínculos.
                String sql = """
                        UPDATE colaborador
                        SET ativo = FALSE,
                            excluido_em = CURRENT_TIMESTAMP
                        WHERE id_colaborador = ?
                          AND ativo = TRUE
                        """;

                int linhas;

                try (PreparedStatement statement = connection.prepareStatement(sql)) {

                    statement.setInt(1, idColaborador);
                    linhas = statement.executeUpdate();
                }

                if (linhas != 1) {
                    throw new IllegalArgumentException(
                            "Não foi possível remover o colaborador.");
                }

                connection.commit();
                return true;

            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

}
