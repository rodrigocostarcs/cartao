CREATE DATABASE caju_dev;
use caju_dev;
DROP TABLE IF EXISTS extratos;
DROP TABLE IF EXISTS carteiras_mccs;
DROP TABLE IF EXISTS mccs;
DROP TABLE IF EXISTS contas_carteiras;
DROP TABLE IF EXISTS carteiras;
DROP TABLE IF EXISTS contas;
DROP TABLE IF EXISTS transacoes_food;
DROP TABLE IF EXISTS transacoes_meal;
DROP TABLE IF EXISTS transacoes_cash;
SHOW TABLES;

CREATE TABLE contas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_conta VARCHAR(255) NOT NULL,
    nome_titular VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE carteiras (
    id_carteira INT AUTO_INCREMENT PRIMARY KEY,
    tipo_beneficio ENUM('FOOD', 'MEAL', 'CASH') NOT NULL,
    descricao VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contas_carteiras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL,
    carteira_id INT NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL,
    saldo_reservado DECIMAL(18,2) NOT NULL DEFAULT 0.00, -- Shadow balance
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conta_id) REFERENCES contas(id),
    FOREIGN KEY (carteira_id) REFERENCES carteiras(id_carteira)
);

CREATE TABLE mccs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_mcc VARCHAR(255) NOT NULL,
    nome_estabelecimento VARCHAR(255) NOT NULL
);

CREATE TABLE carteiras_mccs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    carteira_id INT NOT NULL,
    mcc_id INT NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carteira_id) REFERENCES carteiras(id_carteira),
    FOREIGN KEY (mcc_id) REFERENCES mccs(id)
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

CREATE TABLE transacoes_food (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL REFERENCES contas(id),
    tipo VARCHAR(10) CHECK (tipo IN ('debito', 'credito')),
    valor DECIMAL(18,2) NOT NULL CHECK (valor > 0),
    status VARCHAR(10) CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transacoes_meal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL REFERENCES contas(id),
    tipo VARCHAR(10) CHECK (tipo IN ('debito', 'credito')),
    valor DECIMAL(18,2) NOT NULL CHECK (valor > 0),
    status VARCHAR(10) CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transacoes_cash (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conta_id INT NOT NULL REFERENCES contas(id),
    tipo VARCHAR(10) CHECK (tipo IN ('debito', 'credito')),
    valor DECIMAL(18,2) NOT NULL CHECK (valor > 0),
    status VARCHAR(10) CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estabelecimentos (
    uuid CHAR(36) PRIMARY KEY,
    nome_estabelecimento VARCHAR(255) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);