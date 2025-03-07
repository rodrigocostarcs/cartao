-- 1. Consultar todas as contas:
SELECT * FROM contas;

-- 2. Consultar todas as carteiras:
SELECT * FROM carteiras;

-- 3. Consultar todas as contas_carteiras e trazer os dados da conta e da carteira relacionadas:
SELECT cc.id, cc.conta_id, c.numero_conta, c.nome_titular, cc.carteira_id, ca.tipo_beneficio,
       cc.saldo, cc.saldo_reservado, cc.ativo, cc.criado_em, cc.atualizado_em 
FROM contas_carteiras cc 
JOIN contas c ON cc.conta_id = c.id 
JOIN carteiras ca ON cc.carteira_id = ca.id_carteira;

-- 4. Consultar todos os MCCs:
SELECT * FROM mccs;

-- 5. Consultar todos os MCCs que permitem um tipo específico de carteira:
SELECT m.id, m.codigo_mcc, m.nome_estabelecimento, m.permite_food, m.permite_meal, m.permite_cash
FROM mccs m
WHERE m.permite_food = TRUE;

-- 6. Consultar todos os extratos e trazer os dados da conta e da carteira relacionadas:
SELECT e.id, e.debito, e.credito, e.id_conta, c.numero_conta, c.nome_titular, 
       e.id_carteira, ca.tipo_beneficio, e.data_transacao, e.descricao
FROM extratos e
JOIN contas c ON e.id_conta = c.id
JOIN carteiras ca ON e.id_carteira = ca.id_carteira;

-- 7. Consultar todas as transações:
SELECT * FROM transacoes;

-- 8. Consultar transações por tipo de carteira:
SELECT t.*, c.nome_titular, ca.tipo_beneficio
FROM transacoes t
JOIN contas c ON t.conta_id = c.id
JOIN carteiras ca ON t.carteira_id = ca.id_carteira
WHERE ca.tipo_beneficio = 'food';

-- 9. Consultar todos os estabelecimentos:
SELECT * FROM estabelecimentos;

-- 10. Consultar MCCs por nome de estabelecimento (busca parcial):
SELECT *
FROM mccs
WHERE nome_estabelecimento LIKE '%Restaurante%';

-- 11. Consultar saldo disponível por conta e tipo de carteira:
SELECT c.numero_conta, c.nome_titular, ca.tipo_beneficio, 
       cc.saldo, cc.saldo_reservado, (cc.saldo - cc.saldo_reservado) AS saldo_disponivel
FROM contas_carteiras cc
JOIN contas c ON cc.conta_id = c.id
JOIN carteiras ca ON cc.carteira_id = ca.id_carteira
WHERE cc.ativo = TRUE;

-- 12. Consultar o histórico de transações de uma conta específica:
SELECT t.*, ca.tipo_beneficio
FROM transacoes t
JOIN carteiras ca ON t.carteira_id = ca.id_carteira
WHERE t.conta_id = 1
ORDER BY t.criado_em DESC;

-- 13. Relatório de utilização de MCCs:
SELECT m.codigo_mcc, m.nome_estabelecimento, 
       COUNT(t.id) AS total_transacoes,
       SUM(t.valor) AS valor_total
FROM mccs m
LEFT JOIN transacoes t ON t.mcc_codigo = m.codigo_mcc
GROUP BY m.codigo_mcc, m.nome_estabelecimento
ORDER BY valor_total DESC;

-- 14. Consultar transações por período:
SELECT t.*, c.nome_titular, ca.tipo_beneficio
FROM transacoes t
JOIN contas c ON t.conta_id = c.id
JOIN carteiras ca ON t.carteira_id = ca.id_carteira
WHERE t.criado_em BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY t.criado_em DESC;

-- 15. Verificar MCCs que não possuem permissão para nenhum tipo de carteira:
SELECT *
FROM mccs
WHERE permite_food = FALSE AND permite_meal = FALSE AND permite_cash = FALSE;