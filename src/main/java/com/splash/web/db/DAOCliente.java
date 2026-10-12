package com.splash.web.db;
/*
+ Importa a conexão, modelo, sql
+ Crie a função desejada colocando o modelo como parametro
+ Crie um SQL correspondente para a tabela(String sql).
+ Em um try:
    Crie a conexão,
    Crie um stmt com a query SQL
    defina o valor dos campos com: stmt.set_Tipo_de_Dado(id_param, value_param)
    Execute a operação com stmt.executeUpdate();

    para recuperação de valores adicione:
     + 'ResultSet rs = stmt.executequery()' para armazenar os resultados de resposta.
     + a criação de collections apropriados para os tipos de retorno
     + inclua os valores na collection
     + Retorne a collection
+ Pegue as exceptions com um catch.

Stmt é um container assim como request, ele armazena todas as informações passadas e executa todas de uma vez
 */


import com.splash.web.model.Cliente;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO que realiza o CRUD na tabela {@code cliente}
 */
public class DAOCliente {

    // DAOs de usuarios
    // TODO:
    //  UpdateUsuarios(); DeleteUsuarios()
    //  Create JSPs and servleits to test this DAOs
    // Might use this DAOs as boilerplate to others

    /*--------------------------------------
    Listagem de usuarios
    --------------------------------------*/

    public List<Cliente> getUsuarios() throws SQLException {
        String sql = "SELECT id_cliente, nome, cpf, telefone, email FROM cliente";
        List<Cliente> listaclientes = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                listaclientes.add(mapearCliente(rs));
            }
        }
        return listaclientes;
    }

    public Cliente getusuario(int id) throws SQLException{
        String sql = "SELECT id_cliente, nome, cpf, telefone, email FROM cliente WHERE id_cliente=?";
        try(Connection conn  = DatabaseConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql);){
            stmt.setInt(1, id);

            try(ResultSet rs = stmt.executeQuery()){
                if(!rs.next()) throw new IllegalArgumentException("nenhum usuario encontrado com este ID");;
                return mapearCliente(rs);
            }
        }
    }

    // Converte a linha atual do ResultSet em Cliente sem revalidar (ver Cliente.carregar)
    private Cliente mapearCliente(ResultSet rs) throws SQLException {
        return Cliente.carregar(
                rs.getInt("id_cliente"),
                rs.getString("nome"),
                rs.getString("cpf"),
                rs.getString("telefone"),
                rs.getString("email"));
    }

    /*--------------------------------------
    inserção de usuarios
    --------------------------------------*/


    public void insertUsuario(Cliente cliente) throws SQLException {
        String sql = "INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cliente.getNome());
            stmt.setString(2, cliente.getCpf());
            stmt.setString(3, cliente.getTelefone());
            stmt.setString(4, cliente.getEmail());
            stmt.setString(5, cliente.getSenhaHash());
            stmt.executeUpdate();
        }
    }

    /*--------------------------------------
    Update de usuários
    --------------------------------------*/
    /**
     * Atualiza os {@code clientes} a partir dos valores passados na função.
     *
     *<p>Apenas valores não nulos e não vazios entram no banco. Demais valores permanecem iguais</p>
     *
     * @param Id Identificador do cliente. Obrigatório.
     * @param nome Novo nome do cliente. {@code null} mantém o nome atual.
     * @param telefone Novo telefone do cliente. {@code null} mantém o telefone atual.
     * @param email Novo email do cliente. {@code null} mantém o email atual.
     * @throws IllegalArgumentException Se {@code id} for nulo ou se nenhum valor for preenchido para as colunas.
     * @throws SQLException Se houver algum erro de acesso ao banco.
     * */

    public void updateUsuarios(Integer Id, String nome, String telefone, String email) throws SQLException {

        // verifica se Id é nulo, se for já bloqueia a operação
        // Pode ser necessário tratar isso no back ou front para não interromper a operação.
        if (Id == null) {
            throw new IllegalArgumentException("Um Id precisa ser selecionado para edição");
        }

        // Cria dois objetos de lista para acumular os valores
        // A é listar tudo que vai ser adicionado primeiro e só colocar na query depois
        List<String> colunas = new ArrayList<>();
        List<Object> valores = new ArrayList<>();

        // Adiciona os valores dependendo do que vier na função
        if (nome != null && !nome.isBlank()) {
            colunas.add("nome=?");
            valores.add(nome);
        }
        if (telefone != null && !telefone.isBlank()) {
            colunas.add("telefone=?");
            valores.add(telefone);
        }
        if (email != null && !email.isBlank()) {
            colunas.add("email=?");
            valores.add(email);
        }

        // Verifica se "colunas" está vazio, se estiver não é possível realizar a query, pois não terão valores para o "SET".
        if (colunas.isEmpty()) {
            throw new IllegalArgumentException("Ao menos um valor precisa ser preenchido para edição no Banco");
        }

        // Monta a query concatenando a raiz "UPDATE cliente SET ... WHERE id_cliente=?" com os valores de "colunas", os separando por vírgulas
        String sql = "UPDATE cliente SET " + String.join(", ", colunas) + " WHERE id_cliente=?";
        valores.add(Id);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);){

            // Itera sobre os valores de "Valores", e os atribue para cada coluna declarada anteriormente.
            // Como a relação Colunas X valores é de 1:1, não haverá colunas sem valores.
            for (int i = 0; i < valores.size(); i++) {
                stmt.setObject(i+1, valores.get(i));
            }

            int rowsAffected = stmt.executeUpdate();
            if(rowsAffected == 0){
                throw new IllegalArgumentException("nenhum usuario encontrado com este ID");
            }

        }
    }

    /*--------------------------------------
    Remoção de usuarios
    --------------------------------------*/

    public void deleteusuario(int Id) throws SQLException {
        String sql = "DELETE FROM cliente WHERE id_cliente=?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Id);
            stmt.executeUpdate();
        } catch (RuntimeException e) {
            throw new RuntimeException(e);
        }
    }

    public void deleteusuariosTotal(int Id) throws SQLException {
        String sqlCliente = "DELETE FROM cliente WHERE id_cliente=?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sqlCliente)) {
            stmt.setInt(1, Id);
            stmt.executeUpdate();
        }
    }

}
