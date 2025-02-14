defmodule Caju.Repositories.ContasCarteirasRepository do
  import Ecto.Query, warn: false
  alias Caju.{Repo, ContasCarteiras, Extratos}

  def get_carteiras_by_conta_id(conta_id) do
    from(cc in ContasCarteiras,
      where: cc.conta_id == ^conta_id,
      preload: [:conta, carteira: [:mccs]]
    )
    |> Repo.all()
  end

  def possui_carteira_cash_e_saldo?(conta_id, amount) do
    amount_decimal = Decimal.new(to_string(amount))

    query =
      from cc in ContasCarteiras,
        where: cc.conta_id == ^conta_id and cc.saldo - cc.saldo_reservado >= ^amount_decimal,
        preload: [:conta, carteira: [:mccs]]

    case Repo.one(query) do
      nil ->
        {:error, :saldo_insuficiente}

      conta_carteira ->
        {:ok, conta_carteira}
    end
  end

  def reservar_saldo(conta_carteira, amount) do
    amount_decimal = Decimal.new(to_string(amount))

    query =
      from cc in ContasCarteiras,
        where:
          cc.id == ^conta_carteira.id and cc.conta_id == ^conta_carteira.conta_id and
            cc.saldo - cc.saldo_reservado >= ^amount_decimal,
        update: [inc: [saldo_reservado: ^amount_decimal]]

    case Repo.update_all(query, []) do
      {count, _} when count > 0 ->
        {:ok, conta_carteira}

      _ ->
        {:error, :saldo_insuficiente}
    end
  end

  def lancar_transacao(conta_carteira, amount, merchant) do
    amount_decimal = Decimal.new(to_string(amount))
    negative_amount = Decimal.negate(amount_decimal)

    query =
      from cc in ContasCarteiras,
        where:
          cc.id == ^conta_carteira.id and cc.conta_id == ^conta_carteira.conta_id and
            cc.saldo_reservado >= ^amount_decimal,
        update: [inc: [saldo: ^negative_amount, saldo_reservado: ^negative_amount]]

    Repo.transaction(fn ->
      case Repo.update_all(query, []) do
        {count, _} when count > 0 ->
          extrato = %Extratos{
            debito: amount_decimal,
            credito: Decimal.new("0.00"),
            data_transacao: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
            descricao: "Transação de débito #{merchant}",
            id_conta: conta_carteira.conta_id,
            id_carteira: conta_carteira.carteira_id
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
