package com.splash.web.db;

import com.splash.web.model.Cliente;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Testes unitários da {@link DAOCliente}.
 *
 * <p>Nenhum banco real é usado: {@link DatabaseConnection#getConnection()} é mockado
 * estaticamente e devolve uma {@link Connection} falsa. Assim os testes verificam
 * apenas a lógica da DAO (SQL gerado, parâmetros enviados, mapeamento do ResultSet,
 * validações e fechamento dos recursos).</p>
 */
@ExtendWith(MockitoExtension.class)
class DAOClienteTest {

    @Mock
    private Connection conn;
    @Mock
    private PreparedStatement stmt;
    @Mock
    private ResultSet rs;

    private MockedStatic<DatabaseConnection> dbMock;
    private DAOCliente dao;

    @BeforeEach
    void setUp() {
        dbMock = mockStatic(DatabaseConnection.class);
        dbMock.when(DatabaseConnection::getConnection).thenReturn(conn);
        dao = new DAOCliente();
    }

    @AfterEach
    void tearDown() {
        dbMock.close();
    }

    /*--------------------------------------
    getUsuarios()
    --------------------------------------*/
    @Nested
    @DisplayName("getUsuarios()")
    class GetUsuarios {

        @BeforeEach
        void setUp() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeQuery()).thenReturn(rs);
        }

        @Test
        @DisplayName("mapeia todas as linhas do ResultSet para objetos Cliente")
        void mapeiaTodasAsLinhas() throws SQLException {
            when(rs.next()).thenReturn(true, true, false);
            when(rs.getInt("id_cliente")).thenReturn(1, 2);
            when(rs.getString("nome")).thenReturn("Ana", "Bruno");
            when(rs.getString("cpf")).thenReturn("11122233344", "55566677788");
            when(rs.getString("telefone")).thenReturn("11987654321", "2133334444");
            when(rs.getString("email")).thenReturn("ana@email.com", "bruno@email.com");

            List<Cliente> clientes = dao.getUsuarios();

            assertEquals(2, clientes.size());

            Cliente ana = clientes.get(0);
            assertEquals(1, ana.getId_cliente());
            assertEquals("Ana", ana.getNome());
            assertEquals("11122233344", ana.getCpf());
            assertEquals("11987654321", ana.getTelefone());
            assertEquals("ana@email.com", ana.getEmail());

            Cliente bruno = clientes.get(1);
            assertEquals(2, bruno.getId_cliente());
            assertEquals("Bruno", bruno.getNome());
            assertEquals("55566677788", bruno.getCpf());
            assertEquals("2133334444", bruno.getTelefone());
            assertEquals("bruno@email.com", bruno.getEmail());
        }

        @Test
        @DisplayName("registro fora do padrão no banco não derruba a listagem (não revalida ao carregar)")
        void naoRevalidaDadosDoBanco() throws SQLException {
            when(rs.next()).thenReturn(true, true, false);
            when(rs.getInt("id_cliente")).thenReturn(1, 2);
            when(rs.getString("nome")).thenReturn("Ana", "");
            when(rs.getString("cpf")).thenReturn("11122233344", "123");
            when(rs.getString("telefone")).thenReturn("11987654321", "(11) 9999");
            when(rs.getString("email")).thenReturn("ana@email.com", "email-invalido");

            List<Cliente> clientes = assertDoesNotThrow(() -> dao.getUsuarios());

            assertEquals(2, clientes.size());
            Cliente invalido = clientes.get(1);
            assertEquals("", invalido.getNome());
            assertEquals("123", invalido.getCpf());
            assertEquals("(11) 9999", invalido.getTelefone());
            assertEquals("email-invalido", invalido.getEmail());
        }

        @Test
        @DisplayName("preenche também o id de EntidadeBase (getId) com o id_cliente")
        void preencheIdDaEntidadeBase() throws SQLException {
            when(rs.next()).thenReturn(true, false);
            when(rs.getInt("id_cliente")).thenReturn(10);
            when(rs.getString(anyString())).thenReturn("x");

            Cliente cliente = dao.getUsuarios().get(0);

            assertEquals(10, cliente.getId());
            assertEquals(10, cliente.getId_cliente());
            assertTrue(cliente.isPersistido());
        }

        @Test
        @DisplayName("retorna lista vazia quando a tabela não tem registros")
        void retornaListaVazia() throws SQLException {
            when(rs.next()).thenReturn(false);

            List<Cliente> clientes = dao.getUsuarios();

            assertNotNull(clientes);
            assertTrue(clientes.isEmpty());
        }

        @Test
        @DisplayName("executa o SELECT na tabela cliente sem filtro")
        void executaSelectCorreto() throws SQLException {
            when(rs.next()).thenReturn(false);

            dao.getUsuarios();

            verify(conn).prepareStatement("SELECT id_cliente, nome, cpf, telefone, email FROM cliente");
        }

        @Test
        @DisplayName("fecha ResultSet, PreparedStatement e Connection")
        void fechaRecursos() throws SQLException {
            when(rs.next()).thenReturn(false);

            dao.getUsuarios();

            verify(rs).close();
            verify(stmt).close();
            verify(conn).close();
        }

        @Test
        @DisplayName("propaga SQLException vinda do banco")
        void propagaSQLException() throws SQLException {
            when(rs.next()).thenThrow(new SQLException("falha"));

            assertThrows(SQLException.class, () -> dao.getUsuarios());
        }
    }

    /*--------------------------------------
    getusuario(int id)
    --------------------------------------*/
    @Nested
    @DisplayName("getusuario(id)")
    class GetUsuario {

        @BeforeEach
        void setUp() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeQuery()).thenReturn(rs);
        }

        /** Simula uma linha válida no ResultSet (o modelo valida nome/email/telefone nos setters). */
        private void stubLinhaValida() throws SQLException {
            lenient().when(rs.next()).thenReturn(true);
            lenient().when(rs.getInt("id_cliente")).thenReturn(7);
            lenient().when(rs.getString("nome")).thenReturn("Carla");
            lenient().when(rs.getString("cpf")).thenReturn("99988877766");
            lenient().when(rs.getString("telefone")).thenReturn("31999998888");
            lenient().when(rs.getString("email")).thenReturn("carla@email.com");
        }

        @Test
        @DisplayName("usa SELECT filtrando por id_cliente")
        void executaSelectComWhere() throws SQLException {
            stubLinhaValida();

            dao.getusuario(7);

            verify(conn).prepareStatement(
                    "SELECT id_cliente, nome, cpf, telefone, email FROM cliente WHERE id_cliente=?");
        }

        @Test
        @DisplayName("vincula o id ao parâmetro antes de executar a query")
        void vinculaIdAntesDeExecutar() throws SQLException {
            stubLinhaValida();

            dao.getusuario(7);

            InOrder ordem = inOrder(stmt);
            ordem.verify(stmt).setInt(1, 7);
            ordem.verify(stmt).executeQuery();
        }

        @Test
        @DisplayName("avança o cursor (rs.next) antes de ler as colunas")
        void avancaCursorAntesDeLer() throws SQLException {
            stubLinhaValida();

            dao.getusuario(7);

            InOrder ordem = inOrder(rs);
            ordem.verify(rs).next();
            ordem.verify(rs).getInt("id_cliente");
        }

        @Test
        @DisplayName("mapeia a linha retornada para um Cliente")
        void mapeiaCliente() throws SQLException {
            stubLinhaValida();

            Cliente cliente = dao.getusuario(7);

            assertNotNull(cliente);
            assertEquals(7, cliente.getId_cliente());
            assertEquals("Carla", cliente.getNome());
            assertEquals("99988877766", cliente.getCpf());
            assertEquals("31999998888", cliente.getTelefone());
            assertEquals("carla@email.com", cliente.getEmail());
        }

        @Test
        @DisplayName("lança IllegalArgumentException quando o id não existe")
        void idInexistente() throws SQLException {
            when(rs.next()).thenReturn(false);

            assertThrows(IllegalArgumentException.class, () -> dao.getusuario(999));
        }
    }

    /*--------------------------------------
    insertUsuario(Cliente)
    --------------------------------------*/
    @Nested
    @DisplayName("insertUsuario(cliente)")
    class InsertUsuario {

        private Cliente novoCliente() {
            // Usa setters em vez do construtor completo para isolar a DAO do modelo
            // (o construtor de Pessoa lança NPE em super.getId(); ver resumo em miscelaneous/).
            Cliente cliente = new Cliente();
            cliente.setNome("Diego");
            cliente.setCPF("12345678901");
            cliente.setTelefone("(11) 91234-5678");
            cliente.setEmail("Diego@Email.com");
            cliente.setSenhaHash("hash123");
            return cliente;
        }

        @Test
        @DisplayName("executa INSERT com os campos na ordem correta")
        void insereComParametrosCorretos() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);

            dao.insertUsuario(novoCliente());

            verify(conn).prepareStatement(
                    "INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES (?, ?, ?, ?, ?)");
            InOrder ordem = inOrder(stmt);
            ordem.verify(stmt).setString(1, "Diego");
            ordem.verify(stmt).setString(2, "12345678901");
            ordem.verify(stmt).setString(3, "11912345678");
            ordem.verify(stmt).setString(4, "diego@email.com");
            ordem.verify(stmt).setString(5, "hash123");
            ordem.verify(stmt).executeUpdate();
        }

        @Test
        @DisplayName("fecha PreparedStatement e Connection")
        void fechaRecursos() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);

            dao.insertUsuario(novoCliente());

            verify(stmt).close();
            verify(conn).close();
        }

        @Test
        @DisplayName("propaga a SQLException original (permite ao servlet tratar SQLIntegrityConstraintViolationException)")
        void propagaSQLExceptionOriginal() throws SQLException {
            java.sql.SQLIntegrityConstraintViolationException original = new java.sql.SQLIntegrityConstraintViolationException("cpf duplicado");
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenThrow(original);

            SQLException lancada = assertThrows(SQLException.class, () -> dao.insertUsuario(novoCliente()));
            assertSame(original, lancada);
        }
    }

    /*--------------------------------------
    updateUsuarios(Id, nome, telefone, email)
    --------------------------------------*/
    @Nested
    @DisplayName("updateUsuarios(id, nome, telefone, email)")
    class UpdateUsuarios {

        @Test
        @DisplayName("lança IllegalArgumentException quando o id é nulo, sem abrir conexão")
        void idNulo() {
            assertThrows(IllegalArgumentException.class,
                    () -> dao.updateUsuarios(null, "Nome", "11999998888", "a@b.com"));
            dbMock.verifyNoInteractions();
        }

        @Test
        @DisplayName("lança IllegalArgumentException quando todos os campos são nulos")
        void todosCamposNulos() {
            assertThrows(IllegalArgumentException.class,
                    () -> dao.updateUsuarios(1, null, null, null));
            dbMock.verifyNoInteractions();
        }

        @Test
        @DisplayName("lança IllegalArgumentException quando todos os campos estão em branco")
        void todosCamposEmBranco() {
            assertThrows(IllegalArgumentException.class,
                    () -> dao.updateUsuarios(1, "", "   ", "\t"));
            dbMock.verifyNoInteractions();
        }

        @Test
        @DisplayName("atualiza todos os campos quando todos são informados")
        void atualizaTodosOsCampos() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenReturn(1);

            dao.updateUsuarios(5, "Eva", "11988887777", "eva@email.com");

            verify(conn).prepareStatement("UPDATE cliente SET nome=?, telefone=?, email=? WHERE id_cliente=?");
            verify(stmt).setObject(1, "Eva");
            verify(stmt).setObject(2, "11988887777");
            verify(stmt).setObject(3, "eva@email.com");
            verify(stmt).setObject(4, 5);
            verify(stmt).executeUpdate();
        }

        @Test
        @DisplayName("inclui apenas os campos preenchidos na query")
        void atualizaApenasCamposPreenchidos() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenReturn(1);

            dao.updateUsuarios(5, null, "  ", "novo@email.com");

            verify(conn).prepareStatement("UPDATE cliente SET email=? WHERE id_cliente=?");
            verify(stmt).setObject(1, "novo@email.com");
            verify(stmt).setObject(2, 5);
            verify(stmt, times(2)).setObject(anyInt(), any());
        }

        @Test
        @DisplayName("combina nome e telefone mantendo a ordem das colunas")
        void atualizaNomeETelefone() throws SQLException {
            ArgumentCaptor<String> sql = ArgumentCaptor.forClass(String.class);
            when(conn.prepareStatement(sql.capture())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenReturn(1);

            dao.updateUsuarios(9, "Fábio", "2133334444", null);

            assertEquals("UPDATE cliente SET nome=?, telefone=? WHERE id_cliente=?", sql.getValue());
            verify(stmt).setObject(1, "Fábio");
            verify(stmt).setObject(2, "2133334444");
            verify(stmt).setObject(3, 9);
        }

        @Test
        @DisplayName("lança IllegalArgumentException quando nenhum registro é afetado")
        void idInexistente() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenReturn(0);

            assertThrows(IllegalArgumentException.class,
                    () -> dao.updateUsuarios(999, "Ninguém", null, null));
        }

        @Test
        @DisplayName("fecha PreparedStatement e Connection")
        void fechaRecursos() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenReturn(1);

            dao.updateUsuarios(5, "Eva", null, null);

            verify(stmt).close();
            verify(conn).close();
        }
    }

    /*--------------------------------------
    deleteusuario(int)
    --------------------------------------*/
    @Nested
    @DisplayName("deleteusuario(id)")
    class DeleteUsuario {

        @Test
        @DisplayName("executa DELETE com o id informado")
        void deletaPorId() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);

            dao.deleteusuario(3);

            verify(conn).prepareStatement("DELETE FROM cliente WHERE id_cliente=?");
            InOrder ordem = inOrder(stmt);
            ordem.verify(stmt).setInt(1, 3);
            ordem.verify(stmt).executeUpdate();
            verify(stmt).close();
            verify(conn).close();
        }

        @Test
        @DisplayName("propaga SQLException vinda do banco")
        void propagaSQLException() throws SQLException {
            when(conn.prepareStatement(anyString())).thenReturn(stmt);
            when(stmt.executeUpdate()).thenThrow(new SQLException("FK violada"));

            assertThrows(SQLException.class, () -> dao.deleteusuario(3));
        }
    }
}
