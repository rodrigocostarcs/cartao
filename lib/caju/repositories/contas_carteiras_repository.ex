defmodule Caju.Repositories.ContasCarteirasRepository do
  import Ecto.Query, warn: false
  alias Caju.{Repo, ContasCarteiras, Extratos}

  def buscar_carteiras_por_conta_id(conta_id) do
    from(cc in ContasCarteiras,
      where: cc.conta_id == ^conta_id,
      preload: [:conta, :carteira]
    )
    |> Repo.all()
  end

  def possui_carteira_cash_e_saldo?(conta_id, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    query =
      from cc in ContasCarteiras,
        where: cc.conta_id == ^conta_id and cc.saldo - cc.saldo_reservado >= ^valor_decimal,
        preload: [:conta, carteira: [:mccs]]

    case Repo.one(query) do
      nil ->
        {:error, :saldo_insuficiente}

      conta_carteira ->
        {:ok, conta_carteira}
    end
  end

  def reservar_saldo(conta_carteira, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    query =
      from cc in ContasCarteiras,
        where:
          cc.id == ^conta_carteira.id and cc.conta_id == ^conta_carteira.conta_id and
            cc.saldo - cc.saldo_reservado >= ^valor_decimal,
        update: [inc: [saldo_reservado: ^valor_decimal]]

    case Repo.update_all(query, []) do
      {count, _} when count > 0 ->
        {:ok, conta_carteira}

      _ ->
        {:error, :saldo_insuficiente}
    end
  end

  def lancar_transacao(conta_carteira, valor, estabelecimento) do
    valor_decimal = Decimal.new(to_string(valor))
    negative_valor = Decimal.negate(valor_decimal)

    query =
      from cc in ContasCarteiras,
        where:
          cc.id == ^conta_carteira.id and cc.conta_id == ^conta_carteira.conta_id and
            cc.saldo_reservado >= ^valor_decimal,
        update: [inc: [saldo: ^negative_valor, saldo_reservado: ^negative_valor]]

    Repo.transaction(fn ->
      case Repo.update_all(query, []) do
        {count, _} when count > 0 ->
          extrato = %Extratos{
            debito: valor_decimal,
            credito: Decimal.new("0.00"),
            data_transacao: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
            descricao: "Transação de débito #{estabelecimento}",
            id_conta: conta_carteira.conta_id,
            carteira_id: conta_carteira.carteira_id
          }

          case Repo.insert(extrato) do
            {:ok, _extrato} -> {:ok, conta_carteira}
            {:error, reason} -> Repo.rollback(reason)
          end

        _ ->
          Repo.rollback(:saldo_insuficiente)
      end
    end)
  end
end
