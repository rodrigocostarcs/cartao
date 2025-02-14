1. Consultar todas as contas:

SELECT * FROM contas;

2. Consultar todas as carteiras:

SELECT * FROM carteiras;

3. Consultar todas as contas_carteiras e trazer os dados da conta e da carteira relacionadas:

SELECT cc.id, cc.conta_id, c.numero_conta, c.nome_titular, cc.carteira_id, ca.tipo_beneficio, cc.saldo, cc.saldo_reservado, cc.ativo, cc.criado_em, cc.atualizado_em
FROM contas_carteiras cc
JOIN contas c ON cc.conta_id = c.id
JOIN carteiras ca ON cc.carteira_id = ca.id_carteira;

4. Consultar todos os MCCs:

SELECT * FROM mccs;

5. Consultar todas as carteiras_mccs e trazer os dados da carteira e do MCC relacionados:

SELECT cm.id, cm.carteira_id, ca.tipo_beneficio, ca.descricao, cm.mcc_id, m.codigo_mcc, m.nome_estabelecimento, cm.criado_em
FROM carteiras_mccs cm
JOIN carteiras ca ON cm.carteira_id = ca.id_carteira
JOIN mccs m ON cm.mcc_id = m.id;

6. Consultar todos os extratos e trazer os dados da conta e da carteira relacionadas:

SELECT e.id, e.debito, e.credito, e.id_conta, c.numero_conta, c.nome_titular, e.id_carteira, ca.tipo_beneficio, e.data_transacao, e.descricao
FROM extratos e
JOIN contas c ON e.id_conta = c.id
JOIN carteiras ca ON e.id_carteira = ca.id_carteira;

7. Consultar todas as transações food:

SELECT * FROM transacoes_food;

8. Consultar todas as transações meal:

SELECT * FROM transacoes_meal;

9. Consultar todas as transações cash:

SELECT * FROM transacoes_cash;

10. Consultar todos os estabelecimentos:

SELECT * FROM estabelecimentos;