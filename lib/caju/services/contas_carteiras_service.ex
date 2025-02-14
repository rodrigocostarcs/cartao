defmodule Caju.Services.ContasCarteirasService do
  alias Caju.Repositories.ContasCarteirasRepository
  alias Caju.Repositories.TransacoesRepository

  def saldo_suficiente?(carteiras, amount, mcc, {:ok, mccs_retorno}) do
    amount_decimal = Decimal.new(to_string(amount))

    mccs_retorno_lista =
      case mccs_retorno do
        [%_{} | _] -> mccs_retorno
        %_{} -> [mccs_retorno]
      end

    carteira_mcc_valida =
      Enum.find(carteiras, fn carteira ->
        Enum.any?(carteira.carteira.mccs, fn mcc_associado ->
          Enum.any?(mccs_retorno_lista, fn mcc_retorno ->
            mcc_associado.codigo_mcc == mcc_retorno.codigo_mcc
          end)
        end) and Decimal.compare(carteira.saldo, amount_decimal) != :lt
      end)

    if carteira_mcc_valida do
      {:retorno_mcc, true}
    else
      carteira_cash_valida =
        Enum.find(carteiras, fn carteira ->
          carteira.carteira.tipo_beneficio == :cash and
            Decimal.compare(carteira.saldo, amount_decimal) != :lt
        end)

      if carteira_cash_valida do
        {:carteira_cash, true}
      else
        {:error, :saldo_insuficiente}
      end
    end
  end

  # Essa cláusula nova é específica para tratar o caso do MCC não encontrado
  def saldo_suficiente?(carteiras, amount, _mcc, {:error, :mcc_nao_encontrado}) do
    amount_decimal = Decimal.new(to_string(amount))

    carteira_cash_valida =
      Enum.find(carteiras, fn carteira ->
        carteira.carteira.tipo_beneficio == :cash and
          Decimal.compare(carteira.saldo, amount_decimal) != :lt
      end)

    if carteira_cash_valida do
      {:carteira_cash, true}
    else
      {:error, :saldo_insuficiente}
    end
  end

  def possui_carteira_cash_e_saldo?(carteiras, amount) do
    amount_decimal = Decimal.new(to_string(amount))

    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        carteira.carteira.tipo_beneficio == :cash and
          Decimal.compare(carteira.saldo, amount_decimal) != :lt
      end)

    if carteira_valida do
      {:ok, carteira_valida}
    else
      {:error, :saldo_insuficiente}
    end
  end

  def reservar_saldo(conta_carteira, amount) do
    case faz_reserva_de_saldo(conta_carteira, amount) do
      {:ok, _} ->
        {:ok, conta_carteira}

      {:error, _} ->
        consultar_carteira_cash(conta_carteira, amount)
    end
  end

  defp consultar_carteira_cash(conta_carteira, amount) do
    case ContasCarteirasRepository.possui_carteira_cash_e_saldo?(conta_carteira.conta.id, amount) do
      {:ok, carteira} ->
        case faz_reserva_de_saldo(carteira, amount) do
          {:ok, _} ->
            {:ok, carteira}

          {:error, _} ->
            {:error, :saldo_insuficiente}
        end

      {:error, _} ->
        {:error, :saldo_insuficiente}
    end
  end

  defp faz_reserva_de_saldo(conta_carteira, amount) do
    ContasCarteirasRepository.reservar_saldo(conta_carteira, amount)
  end

  def lancar_transacao(conta_carteira, amount, _mcc, merchant) do
    case ContasCarteirasRepository.lancar_transacao(conta_carteira, amount, merchant) do
      {:ok, _} ->
        gravar_transacao(conta_carteira, amount)

      _ ->
        {:error, :saldo_insuficiente}
    end
  end

  defp gravar_transacao(conta_carteira, amount) do
    case tipo_transacao(conta_carteira.carteira.tipo_beneficio, conta_carteira, amount) do
      {:ok, _} -> {:ok, "00"}
      _ -> {:error, :saldo_insuficiente}
    end
  end

  defp tipo_transacao(:cash, conta_carteira, amount) do
    TransacoesRepository.lancar_transacoes_cash(conta_carteira, "debito", "confirmado", amount)
  end

  defp tipo_transacao(:meal, conta_carteira, amount) do
    TransacoesRepository.lancar_transacoes_meal(conta_carteira, "debito", "confirmado", amount)
  end

  defp tipo_transacao(:food, conta_carteira, amount) do
    TransacoesRepository.lancar_transacoes_food(conta_carteira, "debito", "confirmado", amount)
  end
end
