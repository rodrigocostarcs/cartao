defmodule Cartao.Repositories.SaldoRepository do
  @moduledoc """
  Repository responsável por consultas de saldo no banco de dados.

  Este módulo contém as funções necessárias para acessar e consultar
  informações de saldo das carteiras dos usuários diretamente no banco de dados.

  É a camada de abstração que separa a lógica de negócios (services)
  das operações de banco de dados específicas.
  """

  import Ecto.Query, warn: false
  alias Cartao.Repo
  alias Cartao.Carteiras
  alias Cartao.ContasCarteiras

  @doc """
  Busca o saldo de uma carteira específica para uma conta.

  Esta função realiza uma consulta ao banco de dados para obter as informações
  de saldo de uma carteira específica associada a uma conta.

  ## Parâmetros

    * `conta_id` - ID da conta no banco de dados
    * `tipo_carteira` - Tipo da carteira como atom (:food, :meal, :cash)

  ## Retorno

    * `map` - Mapa contendo as informações de saldo quando encontrado:
       - `carteira_id` - ID da carteira no banco de dados
       - `saldo` - Saldo total da carteira (Decimal)
       - `saldo_reservado` - Saldo reservado para transações (Decimal)
       - `saldo_disponivel` - Saldo disponível para uso (Decimal)
    * `nil` - Quando a combinação de conta e tipo de carteira não é encontrada

  ## Exemplos

      iex> SaldoRepository.buscar_saldo_por_conta_e_tipo(1, :food)
      %{carteira_id: 1, saldo: #Decimal<1000.00>, saldo_reservado: #Decimal<0.00>, saldo_disponivel: #Decimal<1000.00>}

      iex> SaldoRepository.buscar_saldo_por_conta_e_tipo(999, :food)
      nil
  """
  @spec buscar_saldo_por_conta_e_tipo(integer(), atom()) :: map() | nil
  def buscar_saldo_por_conta_e_tipo(conta_id, tipo_carteira) do
    query =
      from cc in ContasCarteiras,
        join: c in Carteiras,
        on: cc.carteira_id == c.id,
        where: cc.conta_id == ^conta_id and c.tipo_beneficio == ^tipo_carteira,
        select: %{
          carteira_id: cc.carteira_id,
          saldo: cc.saldo,
          saldo_reservado: cc.saldo_reservado,
          saldo_disponivel: fragment("? - ?", cc.saldo, cc.saldo_reservado)
        }

    Repo.one(query)
  end
end
