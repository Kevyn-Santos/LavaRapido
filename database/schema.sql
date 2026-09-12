CREATE DATABASE IF NOT EXISTS lava_rapido
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE lava_rapido;

CREATE TABLE cliente (
	id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL
);
CREATE TABLE veiculo (
	id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(60) NOT NULL,
    modelo VARCHAR(60) NOT NULL,
    cor VARCHAR(30),
    
    CONSTRAINT fk_veiculo_cliente
		FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
CREATE TABLE servico(
	id_servico INT AUTO_INCREMENT PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    preco DECIMAL(10,2) NOT NULL,
    
    CONSTRAINT chk_servico_preco
		CHECK (preco >= 0)
);
CREATE TABLE agendamento (
	id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    status ENUM(
		'AGENDADO',
        'CANCELADO',
        'CONCLUIDO'
	) NOT NULL DEFAULT 'AGENDADO',
    
    CONSTRAINT uq_agendamento_veiculo_data_horario
        UNIQUE (id_veiculo, data, horario),
        
	INDEX idx_agendamento_data_horario (data, horario),
	INDEX idx_agendamento_status (status),
        
    CONSTRAINT fk_agendamento_veiculo
		FOREIGN KEY (id_veiculo)
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
CREATE TABLE agendamento_servico (
	id_agendamento INT NOT NULL,
    id_servico INT NOT NULL,
    valor_praticado DECIMAL(10,2) NOT NULL,
    
    PRIMARY KEY (id_agendamento, id_servico),
    
    CONSTRAINT fk_agendamento_servico_agendamento
		FOREIGN KEY (id_agendamento)
        REFERENCES agendamento(id_agendamento)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
        
	CONSTRAINT fk_agendamento_servico_servico
		FOREIGN KEY (id_servico)
        REFERENCES servico(id_servico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        
	CONSTRAINT chk_agendamento_servico_valor
		CHECK (valor_praticado >= 0)
);
CREATE TABLE colaborador (
	id_colaborador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    nivel_acesso ENUM(
		'ADMINISTRADOR',
        'ATENDENTE',
        'OPERACIONAL'
	) NOT NULL DEFAULT 'OPERACIONAL',
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL
);
CREATE TABLE atendimento (
	id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL UNIQUE,
    status ENUM(
		'AGUARDANDO',
        'EM_LAVAGEM',
        'FINALIZADO',
        'ENTREGUE'
	) NOT NULL DEFAULT 'AGUARDANDO',
    data_inicio DATETIME,
    data_fim DATETIME,
    
	INDEX idx_atendimento_status (status),
    
    CONSTRAINT fk_atendimento_agendamento
		FOREIGN KEY (id_agendamento)
        REFERENCES agendamento(id_agendamento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        
	CONSTRAINT chk_atendimento_datas
		CHECK (
			data_fim IS NULL
            OR data_inicio IS NULL
            OR data_fim >= data_inicio
		)
);
CREATE TABLE colaborador_atendimento (
	id_colaborador INT NOT NULL,
    id_atendimento INT NOT NULL,
    
    PRIMARY KEY (id_colaborador, id_atendimento),
    
    CONSTRAINT fk_colaborador_atendimento_colaborador
		FOREIGN KEY (id_colaborador)
        REFERENCES colaborador(id_colaborador)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        
	CONSTRAINT fk_colaborador_atendimento_atendimento
		FOREIGN KEY (id_atendimento)
        REFERENCES atendimento(id_atendimento)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE pagamento (
	id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_atendimento INT NOT NULL UNIQUE,
    data_pagamento DATETIME,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM(
		'DINHEIRO',
        'PIX',
        'CREDITO',
        'DEBITO'        
	) NOT NULL,
    status_pagamento ENUM(
		'PENDENTE',
        'PAGO',
        'CANCELADO'
	) NOT NULL DEFAULT 'PENDENTE',
    
    CONSTRAINT fk_pagamento_atendimento
		FOREIGN KEY (id_atendimento)
        REFERENCES atendimento(id_atendimento)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
        
	CONSTRAINT chk_pagamento_valor
		CHECK (valor >= 0)
);