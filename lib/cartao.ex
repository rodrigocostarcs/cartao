defmodule Cartao do
  @moduledoc """
  O Cartao mantém os contextos que definem o domínio e a lógica de negócio.

  Este módulo serve como ponto de entrada principal para a aplicação Cartao,
  um sistema de processamento de transações financeiras para diferentes
  tipos de carteiras (alimentação, refeição e dinheiro).

  Os contextos são responsáveis por gerenciar seus dados, independentemente
  de virem do banco de dados, de uma API externa ou de outras fontes.

  O sistema implementa:
  - Processamento de transações com validação de MCC
  - Mecanismo de reserva de saldo para garantir consistência
  - Autenticação de estabelecimentos com tokens JWT
  - Gerenciamento de múltiplos tipos de carteiras por usuário
  """
end
