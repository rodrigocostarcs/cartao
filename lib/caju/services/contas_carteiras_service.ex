defmodule Caju.Services.ContasCarteirasService do
  alias Caju.Repositories.ContasCarteirasRepository
  alias Caju.Repositories.TransacoesRepository

  def saldo_suficiente?(carteiras, amount, mcc) do
    amount_decimal = Decimal.new(to_string(amount))

    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        (Enum.any?(carteira.carteira.mccs, fn mcc_associado ->
           mcc_associado.codigo_mcc == mcc
         end) or carteira.carteira.tipo_beneficio == :cash) and
          Decimal.cmp(carteira.saldo, amount_decimal) != :lt
      end)

    if carteira_valida do
      true
    else
      false
    end
  end

  def possui_carteira_cash_e_saldo?(carteiras, amount) do
    amount_decimal = Decimal.new(to_string(amount))

    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        carteira.carteira.tipo_beneficio == :cash and
          Decimal.cmp(carteira.saldo, amount_decimal) != :lt
      end)

    if carteira_valida do
      {:ok, carteira_valida}
    else
      {:error, :saldo_insuficiente}
    end
  end

  def reservar_saldo(carteira, amount) do
    case ContasCarteirasRepository.reservar_saldo(carteira, amount) do
      {:ok, _} ->
        {:ok, carteira} |> IO.inspect()

      {:error, _} ->
        {:error, :saldo_insuficiente} |> IO.inspect()
    end
  end

  def lancar_transacao(carteira, amount, mcc, merchant) do
    case ContasCarteirasRepository.lancar_transacao(carteira, amount, merchant) do
      {:ok, _} ->
        gravar_transacao(carteira, amount)

      _ ->
        {:error, "51"}
    end
  end

  defp gravar_transacao(carteira, amount) do
    case tipo_transacao(carteira.carteira.tipo_beneficio, carteira, amount) do
      {:ok, _} ->
        {:ok, 00}

      _ ->
        {:ok, "51"}
    end
  end

  defp tipo_transacao(:cash, carteira, amount) do
    TransacoesRepository.lancar_transacoes_cash(carteira, "debito", "confirmado", amount)
  end

  defp tipo_transacao(:meal, carteira, amount) do
    TransacoesRepository.lancar_transacoes_meal(carteira, "debito", "confirmado", amount)
  end

  defp tipo_transacao(:food, carteira, amount) do
    TransacoesRepository.lancar_transacoes_food(carteira, "debito", "confirmado", amount)
  end
end
