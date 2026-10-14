package com.example;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public final class LavaRapidoRepository {

    public record Cliente(int id, String nome, String telefone, String email) {
        public int getId() { return id; }
        public String getNome() { return nome; }
        public String getTelefone() { return telefone; }
        public String getEmail() { return email; }
    }

    public record Veiculo(int id, String placa, String marca, String modelo, String cor) {
        public int getId() { return id; }
        public String getPlaca() { return placa; }
        public String getMarca() { return marca; }
        public String getModelo() { return modelo; }
        public String getCor() { return cor; }
    }

    public record Servico(int id, String nome, String descricao, BigDecimal preco) {
        public int getId() { return id; }
        public String getNome() { return nome; }
        public String getDescricao() { return descricao; }
        public BigDecimal getPreco() { return preco; }
    }

    public record Agendamento(int id, String placa, String veiculo, LocalDate data, String horario,
            String status, BigDecimal total, String statusPagamento, String formaPagamento) {
        public int getId() { return id; }
        public String getPlaca() { return placa; }
        public String getVeiculo() { return veiculo; }
        public LocalDate getData() { return data; }
        public String getHorario() { return horario; }
        public String getStatus() { return status; }
        public BigDecimal getTotal() { return total; }
        public String getStatusPagamento() { return statusPagamento; }
        public String getFormaPagamento() { return formaPagamento; }
    }

    public record Colaborador(int id, String nome, String cargo, String nivelAcesso, String email) {
        public int getId() { return id; }
        public String getNome() { return nome; }
        public String getCargo() { return cargo; }
        public String getNivelAcesso() { return nivelAcesso; }
        public String getEmail() { return email; }
    }

    public record Atendimento(int id, int idAgendamento, String cliente, String placa, LocalDate data,
            String horario, String status, String statusAgendamento, String colaboradores,
            String idsColaboradores) {
        public int getId() { return id; }
        public int getIdAgendamento() { return idAgendamento; }
        public String getCliente() { return cliente; }
        public String getPlaca() { return placa; }
        public LocalDate getData() { return data; }
        public String getHorario() { return horario; }
        public String getStatus() { return status; }
        public String getStatusAgendamento() { return statusAgendamento; }
        public String getColaboradores() { return colaboradores; }
        public String getIdsColaboradores() { return idsColaboradores; }
    }

    public record Pagamento(int id, int idAgendamento, String cliente, String placa, LocalDate data,
            String horario, BigDecimal valor, String forma, String status) {
        public int getId() { return id; }
        public int getIdAgendamento() { return idAgendamento; }
        public String getCliente() { return cliente; }
        public String getPlaca() { return placa; }
        public LocalDate getData() { return data; }
        public String getHorario() { return horario; }
        public BigDecimal getValor() { return valor; }
        public String getForma() { return forma; }
        public String getStatus() { return status; }
    }

    private LavaRapidoRepository() {
    }

    static void cadastrarCliente(String nome, String cpf, String telefone, String email, String senha)
            throws SQLException {
        String sql = "INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, cpf.trim());
            statement.setString(3, telefone.trim());
            statement.setString(4, email.trim().toLowerCase());
            statement.setString(5, Passwords.hash(senha));
            statement.executeUpdate();
        }
    }

    static Cliente obterClientePorId(int idCliente) throws SQLException {
        String sql = "SELECT id_cliente, nome, telefone, email FROM cliente WHERE id_cliente = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return new Cliente(result.getInt("id_cliente"), result.getString("nome"),
                            result.getString("telefone"), result.getString("email"));
                }
                return null;
            }
        }
    }

    static void atualizarCliente(int idCliente, String nome, String telefone, String email,
            String novaSenha) throws SQLException {
        String sql = novaSenha == null || novaSenha.isBlank()
                ? "UPDATE cliente SET nome = ?, telefone = ?, email = ? WHERE id_cliente = ?"
                : "UPDATE cliente SET nome = ?, telefone = ?, email = ?, senha_hash = ? WHERE id_cliente = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, telefone.trim());
            statement.setString(3, email.trim().toLowerCase());
            if (novaSenha != null && !novaSenha.isBlank()) {
                statement.setString(4, Passwords.hash(novaSenha));
                statement.setInt(5, idCliente);
            } else {
                statement.setInt(4, idCliente);
            }
            if (statement.executeUpdate() != 1) {
                throw new SQLException("Cliente não encontrado para atualização.");
            }
        }
    }

    static boolean clientePossuiAgendamentoPendente(int idCliente) throws SQLException {
        String sql = "SELECT 1 FROM agendamento a "
                + "JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "WHERE v.id_cliente = ? AND a.status = 'AGENDADO' LIMIT 1";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        }
    }

    static boolean excluirCliente(int idCliente, String senha) throws SQLException {
        if (clientePossuiAgendamentoPendente(idCliente)) {
            return false;
        }

        String sql = "SELECT senha_hash FROM cliente WHERE id_cliente = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement select = connection.prepareStatement(sql)) {
            select.setInt(1, idCliente);
            try (ResultSet result = select.executeQuery()) {
                if (!result.next() || !Passwords.matches(senha, result.getString("senha_hash"))) {
                    return false;
                }
            }
        }

        String deleteSql = "DELETE FROM cliente WHERE id_cliente = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(deleteSql)) {
            statement.setInt(1, idCliente);
            return statement.executeUpdate() == 1;
        }
    }

    static Cliente autenticarCliente(String email, String senha) throws SQLException {
        String sql = "SELECT id_cliente, nome, telefone, email, senha_hash FROM cliente WHERE email = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email.trim().toLowerCase());
            try (ResultSet result = statement.executeQuery()) {
                if (result.next() && Passwords.matches(senha, result.getString("senha_hash"))) {
                    return new Cliente(result.getInt("id_cliente"), result.getString("nome"),
                            result.getString("telefone"), result.getString("email"));
                }
                return null;
            }
        }
    }

    static Colaborador autenticarColaborador(String email, String senha) throws SQLException {
        String sql = "SELECT id_colaborador, nome, cargo, nivel_acesso, email, senha_hash "
                + "FROM colaborador WHERE email = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email.trim().toLowerCase());
            try (ResultSet result = statement.executeQuery()) {
                if (result.next() && Passwords.matches(senha, result.getString("senha_hash"))) {
                    return new Colaborador(result.getInt("id_colaborador"), result.getString("nome"),
                            result.getString("cargo"), result.getString("nivel_acesso"),
                            result.getString("email"));
                }
                return null;
            }
        }
    }

    static List<Veiculo> listarVeiculos(int idCliente) throws SQLException {
        String sql = "SELECT id_veiculo, placa, marca, modelo, cor FROM veiculo "
                + "WHERE id_cliente = ? ORDER BY placa";
        List<Veiculo> veiculos = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    veiculos.add(new Veiculo(result.getInt("id_veiculo"), result.getString("placa"),
                            result.getString("marca"), result.getString("modelo"), result.getString("cor")));
                }
            }
        }
        return veiculos;
    }

    static void adicionarVeiculo(int idCliente, String placa, String marca, String modelo, String cor)
            throws SQLException {
        String sql = "INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            statement.setString(2, placa.trim().toUpperCase());
            statement.setString(3, marca.trim());
            statement.setString(4, modelo.trim());
            statement.setString(5, cor == null || cor.isBlank() ? null : cor.trim());
            statement.executeUpdate();
        }
    }

    static boolean atualizarVeiculo(int idCliente, int idVeiculo, String placa, String marca,
            String modelo, String cor) throws SQLException {
        String sql = "UPDATE veiculo SET placa = ?, marca = ?, modelo = ?, cor = ? "
                + "WHERE id_cliente = ? AND id_veiculo = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, placa.trim().toUpperCase());
            statement.setString(2, marca.trim());
            statement.setString(3, modelo.trim());
            statement.setString(4, cor == null || cor.isBlank() ? null : cor.trim());
            statement.setInt(5, idCliente);
            statement.setInt(6, idVeiculo);
            return statement.executeUpdate() == 1;
        }
    }

    static boolean removerVeiculo(int idCliente, int idVeiculo) throws SQLException {
        String sql = "DELETE FROM veiculo WHERE id_cliente = ? AND id_veiculo = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            statement.setInt(2, idVeiculo);
            return statement.executeUpdate() == 1;
        }
    }

    static List<Servico> listarServicos() throws SQLException {
        String sql = "SELECT id_servico, nome, descricao, preco FROM servico ORDER BY nome";
        List<Servico> servicos = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                servicos.add(new Servico(result.getInt("id_servico"), result.getString("nome"),
                        result.getString("descricao"), result.getBigDecimal("preco")));
            }
        }
        return servicos;
    }

    static void salvarServico(Integer idServico, String nome, String descricao, BigDecimal preco)
            throws SQLException {
        boolean atualizar = idServico != null;
        String sql = atualizar
                ? "UPDATE servico SET nome = ?, descricao = ?, preco = ? WHERE id_servico = ?"
                : "INSERT INTO servico (nome, descricao, preco) VALUES (?, ?, ?)";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, nome.trim());
            statement.setString(2, descricao == null || descricao.isBlank() ? null : descricao.trim());
            statement.setBigDecimal(3, preco);
            if (atualizar) {
                statement.setInt(4, idServico);
            }
            if (statement.executeUpdate() != 1) {
                throw new SQLException("O serviço não foi encontrado para atualização.");
            }
        }
    }

    static boolean removerServico(int idServico) throws SQLException {
        String sql = "DELETE FROM servico WHERE id_servico = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idServico);
            return statement.executeUpdate() == 1;
        }
    }

    static void criarAgendamento(int idCliente, int idVeiculo, LocalDate data, String horario,
            List<Integer> idsServicos) throws SQLException {
        Set<Integer> servicosUnicos = new LinkedHashSet<>(idsServicos);
        if (servicosUnicos.isEmpty() || servicosUnicos.size() != idsServicos.size()) {
            throw new IllegalArgumentException("Selecione ao menos um serviço, sem repetições.");
        }
        String insertAppointment = "INSERT INTO agendamento (id_veiculo, data, horario) VALUES (?, ?, ?)";
        String insertService = "INSERT INTO agendamento_servico "
                + "(id_agendamento, id_servico, valor_praticado) VALUES (?, ?, ?)";
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement vehicle = connection.prepareStatement(
                        "SELECT 1 FROM veiculo WHERE id_veiculo = ? AND id_cliente = ?")) {
                    vehicle.setInt(1, idVeiculo);
                    vehicle.setInt(2, idCliente);
                    try (ResultSet result = vehicle.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException("O veículo selecionado não pertence à sua conta.");
                        }
                    }
                }
                List<Servico> selecionados = new ArrayList<>();
                BigDecimal total = BigDecimal.ZERO;
                try (PreparedStatement price = connection.prepareStatement(
                        "SELECT preco FROM servico WHERE id_servico = ?")) {
                    for (int idServico : servicosUnicos) {
                        price.setInt(1, idServico);
                        try (ResultSet result = price.executeQuery()) {
                            if (!result.next()) {
                                throw new IllegalArgumentException("Um dos serviços selecionados não existe.");
                            }
                            BigDecimal preco = result.getBigDecimal("preco");
                            selecionados.add(new Servico(idServico, null, null, preco));
                            total = total.add(preco);
                        }
                    }
                }
                int idAgendamento;
                try (PreparedStatement appointment = connection.prepareStatement(insertAppointment,
                        Statement.RETURN_GENERATED_KEYS)) {
                    appointment.setInt(1, idVeiculo);
                    appointment.setDate(2, Date.valueOf(data));
                    appointment.setString(3, horario);
                    appointment.executeUpdate();
                    try (ResultSet keys = appointment.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Não foi possível obter o identificador do agendamento.");
                        }
                        idAgendamento = keys.getInt(1);
                    }
                }
                try (PreparedStatement service = connection.prepareStatement(insertService)) {
                    for (Servico servico : selecionados) {
                        service.setInt(1, idAgendamento);
                        service.setInt(2, servico.id());
                        service.setBigDecimal(3, servico.preco());
                        service.addBatch();
                    }
                    service.executeBatch();
                }
                try (PreparedStatement attendance = connection.prepareStatement(
                        "INSERT INTO atendimento (id_agendamento) VALUES (?)");
                        PreparedStatement payment = connection.prepareStatement(
                                "INSERT INTO pagamento (id_agendamento, valor) VALUES (?, ?)")) {
                    attendance.setInt(1, idAgendamento);
                    attendance.executeUpdate();
                    payment.setInt(1, idAgendamento);
                    payment.setBigDecimal(2, total);
                    payment.executeUpdate();
                }
                connection.commit();
            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    static List<Agendamento> listarAgendamentosCliente(int idCliente) throws SQLException {
        String sql = "SELECT a.id_agendamento, v.placa, CONCAT(v.marca, ' ', v.modelo) AS veiculo, "
                + "a.data, a.horario, a.status, COALESCE(SUM(ags.valor_praticado), 0) AS total, "
                + "MAX(p.status_pagamento) AS status_pagamento, MAX(p.forma_pagamento) AS forma_pagamento "
                + "FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "LEFT JOIN agendamento_servico ags ON ags.id_agendamento = a.id_agendamento "
                + "LEFT JOIN pagamento p ON p.id_agendamento = a.id_agendamento "
                + "WHERE v.id_cliente = ? GROUP BY a.id_agendamento ORDER BY a.data DESC, a.horario DESC";
        List<Agendamento> agendamentos = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idCliente);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    agendamentos.add(new Agendamento(result.getInt("id_agendamento"),
                            result.getString("placa"), result.getString("veiculo"),
                            result.getDate("data").toLocalDate(), result.getString("horario"),
                            result.getString("status"), result.getBigDecimal("total"),
                            result.getString("status_pagamento"), result.getString("forma_pagamento")));
                }
            }
        }
        return agendamentos;
    }

    static boolean cancelarAgendamento(int idCliente, int idAgendamento) throws SQLException {
        String sql = "UPDATE agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "SET a.status = 'CANCELADO' WHERE a.id_agendamento = ? AND v.id_cliente = ? "
                + "AND a.status = 'AGENDADO'";
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                boolean cancelado;
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, idAgendamento);
                    statement.setInt(2, idCliente);
                    cancelado = statement.executeUpdate() == 1;
                }
                if (cancelado) {
                    try (PreparedStatement payment = connection.prepareStatement(
                            "UPDATE pagamento SET status_pagamento = 'CANCELADO' "
                                    + "WHERE id_agendamento = ? AND status_pagamento = 'PENDENTE'")) {
                        payment.setInt(1, idAgendamento);
                        payment.executeUpdate();
                    }
                }
                connection.commit();
                return cancelado;
            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    static void cadastrarColaborador(String nome, String cargo, String nivelAcesso, String email,
            String senha) throws SQLException {
        salvarColaborador(null, nome, cargo, nivelAcesso, email, senha);
    }

    static void salvarColaborador(Integer idColaborador, String nome, String cargo, String nivelAcesso,
            String email, String senha) throws SQLException {
        boolean atualizar = idColaborador != null;
        String sql = atualizar
                ? "UPDATE colaborador SET nome = ?, cargo = ?, nivel_acesso = ?, email = ?"
                        + (senha != null && !senha.isBlank() ? ", senha_hash = ?" : "")
                        + " WHERE id_colaborador = ?"
                : "INSERT INTO colaborador (nome, cargo, nivel_acesso, email, senha_hash) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = 1;
            statement.setString(index++, nome.trim());
            statement.setString(index++, cargo.trim());
            statement.setString(index++, nivelAcesso);
            statement.setString(index++, email.trim().toLowerCase());
            if (atualizar) {
                if (senha != null && !senha.isBlank()) {
                    statement.setString(index++, Passwords.hash(senha));
                }
                statement.setInt(index, idColaborador);
            } else {
                statement.setString(index++, Passwords.hash(senha));
            }
            if (statement.executeUpdate() != 1) {
                throw new SQLException("O colaborador não foi encontrado para atualização.");
            }
        }
    }

    static boolean removerColaborador(int idColaborador) throws SQLException {
        String sql = "DELETE FROM colaborador WHERE id_colaborador = ?";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, idColaborador);
            return statement.executeUpdate() == 1;
        }
    }

    static List<Colaborador> listarColaboradores() throws SQLException {
        List<Colaborador> colaboradores = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(
                        "SELECT id_colaborador, nome, cargo, nivel_acesso, email "
                                + "FROM colaborador ORDER BY nome");
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                colaboradores.add(new Colaborador(result.getInt("id_colaborador"),
                        result.getString("nome"), result.getString("cargo"),
                        result.getString("nivel_acesso"), result.getString("email")));
            }
        }
        return colaboradores;
    }

    static List<Atendimento> listarAtendimentos() throws SQLException {
        String sql = "SELECT at.id_atendimento, a.id_agendamento, c.nome AS cliente, v.placa, "
                + "a.data, a.horario, at.status, a.status AS status_agendamento, "
                + "COALESCE(GROUP_CONCAT(col.nome ORDER BY col.nome SEPARATOR ', '), '') AS colaboradores, "
                + "COALESCE(GROUP_CONCAT(ca.id_colaborador ORDER BY ca.id_colaborador), '') AS ids_colaboradores "
                + "FROM atendimento at JOIN agendamento a ON a.id_agendamento = at.id_agendamento "
                + "JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "JOIN cliente c ON c.id_cliente = v.id_cliente "
                + "LEFT JOIN colaborador_atendimento ca ON ca.id_atendimento = at.id_atendimento "
                + "LEFT JOIN colaborador col ON col.id_colaborador = ca.id_colaborador "
                + "GROUP BY at.id_atendimento ORDER BY a.data, a.horario";
        List<Atendimento> atendimentos = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                atendimentos.add(new Atendimento(result.getInt("id_atendimento"),
                        result.getInt("id_agendamento"), result.getString("cliente"),
                        result.getString("placa"), result.getDate("data").toLocalDate(),
                        result.getString("horario"), result.getString("status"),
                        result.getString("status_agendamento"), result.getString("colaboradores"),
                        result.getString("ids_colaboradores")));
            }
        }
        return atendimentos;
    }

    static void atualizarAtendimento(int idAtendimento, String status, List<Integer> idsColaboradores)
            throws SQLException {
        String select = "SELECT at.status, a.status AS status_agendamento "
                + "FROM atendimento at JOIN agendamento a ON a.id_agendamento = at.id_agendamento "
                + "WHERE at.id_atendimento = ? FOR UPDATE";
        String update = "UPDATE atendimento SET status = ?, "
                + "data_inicio = CASE WHEN ? = 'EM_LAVAGEM' AND data_inicio IS NULL "
                + "THEN CURRENT_TIMESTAMP ELSE data_inicio END, "
                + "data_fim = CASE WHEN ? IN ('FINALIZADO', 'ENTREGUE') AND data_fim IS NULL "
                + "THEN CURRENT_TIMESTAMP ELSE data_fim END WHERE id_atendimento = ?";
        try (Connection connection = Database.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(select)) {
                    statement.setInt(1, idAtendimento);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalArgumentException("Atendimento não encontrado.");
                        }
                        String atual = result.getString("status");
                        if ("CANCELADO".equals(result.getString("status_agendamento"))
                                || !transicaoPermitida(atual, status)) {
                            throw new IllegalArgumentException(
                                    "Atendimento cancelado ou transição de status não permitida.");
                        }
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(update)) {
                    statement.setString(1, status);
                    statement.setString(2, status);
                    statement.setString(3, status);
                    statement.setInt(4, idAtendimento);
                    statement.executeUpdate();
                }
                if ("FINALIZADO".equals(status) || "ENTREGUE".equals(status)) {
                    try (PreparedStatement statement = connection.prepareStatement(
                            "UPDATE agendamento SET status = 'CONCLUIDO' WHERE id_agendamento = "
                                    + "(SELECT id_agendamento FROM atendimento WHERE id_atendimento = ?)")) {
                        statement.setInt(1, idAtendimento);
                        statement.executeUpdate();
                    }
                }
                try (PreparedStatement delete = connection.prepareStatement(
                        "DELETE FROM colaborador_atendimento WHERE id_atendimento = ?")) {
                    delete.setInt(1, idAtendimento);
                    delete.executeUpdate();
                }
                try (PreparedStatement insert = connection.prepareStatement(
                        "INSERT INTO colaborador_atendimento (id_colaborador, id_atendimento) VALUES (?, ?)")) {
                    for (int idColaborador : new LinkedHashSet<>(idsColaboradores)) {
                        insert.setInt(1, idColaborador);
                        insert.setInt(2, idAtendimento);
                        insert.addBatch();
                    }
                    insert.executeBatch();
                }
                connection.commit();
            } catch (SQLException | RuntimeException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    private static boolean transicaoPermitida(String atual, String proximo) {
        return switch (atual) {
            case "AGUARDANDO" -> "AGUARDANDO".equals(proximo) || "EM_LAVAGEM".equals(proximo);
            case "EM_LAVAGEM" -> "EM_LAVAGEM".equals(proximo) || "FINALIZADO".equals(proximo);
            case "FINALIZADO" -> "FINALIZADO".equals(proximo) || "ENTREGUE".equals(proximo);
            case "ENTREGUE" -> "ENTREGUE".equals(proximo);
            default -> false;
        };
    }

    static List<Pagamento> listarPagamentos() throws SQLException {
        String sql = "SELECT p.id_pagamento, p.id_agendamento, c.nome AS cliente, v.placa, "
                + "a.data, a.horario, p.valor, p.forma_pagamento, p.status_pagamento "
                + "FROM pagamento p JOIN agendamento a ON a.id_agendamento = p.id_agendamento "
                + "JOIN veiculo v ON v.id_veiculo = a.id_veiculo "
                + "JOIN cliente c ON c.id_cliente = v.id_cliente "
                + "ORDER BY a.data DESC, a.horario DESC";
        List<Pagamento> pagamentos = new ArrayList<>();
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                pagamentos.add(new Pagamento(result.getInt("id_pagamento"),
                        result.getInt("id_agendamento"), result.getString("cliente"),
                        result.getString("placa"), result.getDate("data").toLocalDate(),
                        result.getString("horario"), result.getBigDecimal("valor"),
                        result.getString("forma_pagamento"), result.getString("status_pagamento")));
            }
        }
        return pagamentos;
    }

    static void atualizarPagamento(int idPagamento, String status, String forma) throws SQLException {
        String sql = "UPDATE pagamento SET status_pagamento = ?, "
                + "forma_pagamento = CASE WHEN ? = 'PAGO' THEN ? ELSE forma_pagamento END, "
                + "data_pagamento = CASE WHEN ? = 'PAGO' THEN CURRENT_TIMESTAMP ELSE data_pagamento END "
                + "WHERE id_pagamento = ? AND status_pagamento = 'PENDENTE'";
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setString(2, status);
            statement.setString(3, forma);
            statement.setString(4, status);
            statement.setInt(5, idPagamento);
            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException("Pagamento não encontrado ou já processado.");
            }
        }
    }

    static boolean existeAdministrador() throws SQLException {
        try (Connection connection = Database.getConnection();
                PreparedStatement statement = connection.prepareStatement(
                        "SELECT 1 FROM colaborador WHERE nivel_acesso = 'ADMINISTRADOR' LIMIT 1");
                ResultSet result = statement.executeQuery()) {
            return result.next();
        }
    }

    static void criarAdministradorInicial(String nome, String cargo, String email, String senha)
            throws SQLException {
        try (Connection connection = Database.getConnection()) {
            try (PreparedStatement lock = connection.prepareStatement("SELECT GET_LOCK(?, 5)")) {
                lock.setString(1, "lava_rapido_initial_admin");
                try (ResultSet result = lock.executeQuery()) {
                    if (!result.next() || result.getInt(1) != 1) {
                        throw new SQLException("Não foi possível obter o bloqueio para a configuração inicial.");
                    }
                }
            }
            try {
                if (existeAdministrador()) {
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
}
