-- Inserir dados nas tabelas
INSERT INTO contas (numero_conta, nome_titular) VALUES ('123456', 'João Silva');
INSERT INTO contas (numero_conta, nome_titular) VALUES ('654321', 'Maria Oliveira');
INSERT INTO contas (numero_conta, nome_titular) VALUES ('789012', 'Rodrigo Costa');
""
INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('FOOD', 'Benefício Alimentação');
INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('MEAL', 'Benefício Refeição');
INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('CASH', 'Benefício Dinheiro');

INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (1, 1, 1000.00, TRUE);
INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (2, 2, 2000.00, TRUE);
INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (3, 3, 3000.00, TRUE);

INSERT INTO mccs (codigo_mcc, nome_estabelecimento) VALUES ('5411', 'Supermercado A');
INSERT INTO mccs (codigo_mcc, nome_estabelecimento) VALUES ('5412', 'Supermercado B');
INSERT INTO mccs (codigo_mcc, nome_estabelecimento) VALUES ('5811', 'Restaurante A');
INSERT INTO mccs (codigo_mcc, nome_estabelecimento) VALUES ('5812', 'Restaurante B');
INSERT INTO mccs (codigo_mcc, nome_estabelecimento) VALUES ('5999', 'Loja de Conveniência');

-- Associando MCCs de FOOD
INSERT INTO carteiras_mccs (carteira_id, mcc_id) VALUES (1, 1); -- Supermercado A
INSERT INTO carteiras_mccs (carteira_id, mcc_id) VALUES (1, 2); -- Supermercado B

-- Associando MCCs de MEAL
INSERT INTO carteiras_mccs (carteira_id, mcc_id) VALUES (2, 3); -- Restaurante A
INSERT INTO carteiras_mccs (carteira_id, mcc_id) VALUES (2, 4); -- Restaurante B

-- Associando MCCs de CASH
INSERT INTO carteiras_mccs (carteira_id, mcc_id) VALUES (3, 5); -- Loja de Conveniência

INSERT INTO estabelecimentos (nome_estabelecimento, senha_hash, uuid) 
VALUES ('Estabelecimento Exemplo', '$pbkdf2-sha512$160000$/CrIInlvYGHTbkQQ2H8jaQ$0GhMgH2tWaypbZfGGy5AKUviZTBeo9Yd4VHZQyKtWhmuFZG/4CMxowQMMJGFh5lLIThBzr7qOIX2aPS.bQ120w', 'fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea');