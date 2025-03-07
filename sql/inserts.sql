-- Inserir dados nas tabelas
INSERT INTO contas (numero_conta, nome_titular) VALUES ('123456', 'João Silva');
INSERT INTO contas (numero_conta, nome_titular) VALUES ('654321', 'Maria Oliveira');
INSERT INTO contas (numero_conta, nome_titular) VALUES ('789012', 'Rodrigo Costa');

INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('food', 'Benefício Alimentação');
INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('meal', 'Benefício Refeição');
INSERT INTO carteiras (tipo_beneficio, descricao) VALUES ('cash', 'Benefício Dinheiro');

INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (1, 1, 1000.00, TRUE);
INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (2, 2, 2000.00, TRUE);
INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (3, 2, 3000.00, TRUE);
INSERT INTO contas_carteiras (conta_id, carteira_id, saldo, ativo) VALUES (3, 3, 3000.00, TRUE);

-- Inserir MCCs com as permissões de tipos de carteira
INSERT INTO mccs (codigo_mcc, nome_estabelecimento, permite_food, permite_meal, permite_cash) 
VALUES ('5411', 'Supermercado A', TRUE, FALSE, FALSE);

INSERT INTO mccs (codigo_mcc, nome_estabelecimento, permite_food, permite_meal, permite_cash) 
VALUES ('5412', 'Supermercado B', TRUE, FALSE, FALSE);

INSERT INTO mccs (codigo_mcc, nome_estabelecimento, permite_food, permite_meal, permite_cash) 
VALUES ('5811', 'Restaurante A', FALSE, TRUE, FALSE);

INSERT INTO mccs (codigo_mcc, nome_estabelecimento, permite_food, permite_meal, permite_cash) 
VALUES ('5812', 'Restaurante B', FALSE, TRUE, FALSE);

INSERT INTO mccs (codigo_mcc, nome_estabelecimento, permite_food, permite_meal, permite_cash) 
VALUES ('5999', 'Loja de Conveniência', FALSE, FALSE, TRUE);

INSERT INTO estabelecimentos (nome_estabelecimento, senha_hash, uuid)  -- senha = "senha_secreta"
VALUES ('Estabelecimento Exemplo', '$pbkdf2-sha512$160000$/CrIInlvYGHTbkQQ2H8jaQ$0GhMgH2tWaypbZfGGy5AKUviZTBeo9Yd4VHZQyKtWhmuFZG/4CMxowQMMJGFh5lLIThBzr7qOIX2aPS.bQ120w', 'fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea');