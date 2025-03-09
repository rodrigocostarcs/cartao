defmodule Caju.Repositories.SaldoRepository do
  import Ecto.Query, warn: false
  alias Caju.Repo
  alias Caju.Carteiras
  alias Caju.ContasCarteiras

  @doc """
  Busca o saldo de uma carteira específica para uma conta.

  ## Parâmetros

    * `conta_id` - ID da conta
    * `tipo_carteira` - Tipo da carteira como atom (:food, :meal, :cash)
  """
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
