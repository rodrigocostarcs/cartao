CREATE DATABASE caju_dev;
use caju_dev;
DROP TABLE IF EXISTS extratos;
DROP TABLE IF EXISTS mccs;
DROP TABLE IF EXISTS transacoes;
DROP TABLE IF EXISTS contas_carteiras;
DROP TABLE IF EXISTS carteiras;
DROP TABLE IF EXISTS contas;
DROP TABLE IF EXISTS estabelecimentos;
SHOW TABLES;

CREATE TABLE contas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_conta VARCHAR(255) NOT NULL unique,
    nome_titular VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE carteiras (
    id_carteira INT AUTO_INCREMENT PRIMARY KEY,
    tipo_beneficio ENUM('food', 'meal', 'cash') NOT NULL,
    descricao VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contas_carteiras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL,
    carteira_id INT NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL,
    saldo_reservado DECIMAL(18,2) NOT NULL DEFAULT 0.00, -- Shadow balance
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conta_id) REFERENCES contas(id),
    FOREIGN KEY (carteira_id) REFERENCES carteiras(id_carteira)
);

CREATE TABLE mccs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_mcc VARCHAR(255) NOT NULL UNIQUE,
    nome_estabelecimento VARCHAR(255) NOT NULL,
    permite_food BOOLEAN NOT NULL DEFAULT FALSE,
    permite_meal BOOLEAN NOT NULL DEFAULT FALSE,
    permite_cash BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE extratos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    debito DECIMAL(10, 2),
    credito DECIMAL(10, 2),
    id_conta INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descricao VARCHAR(255),
    id_carteira INT NOT NULL,
    FOREIGN KEY (id_conta) REFERENCES contas(id),
    FOREIGN KEY (id_carteira) REFERENCES carteiras(id_carteira)
);

CREATE TABLE transacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL,
    carteira_id INT NOT NULL,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('debito', 'credito')),
    valor DECIMAL(18,2) NOT NULL CHECK (valor > 0),
    status VARCHAR(10) NOT NULL CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
    estabelecimento VARCHAR(255),
    mcc_codigo VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conta_id) REFERENCES contas(id),
    FOREIGN KEY (carteira_id) REFERENCES carteiras(id_carteira)
);

CREATE TABLE estabelecimentos (
    uuid CHAR(36) PRIMARY KEY,
    nome_estabelecimento VARCHAR(255) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);