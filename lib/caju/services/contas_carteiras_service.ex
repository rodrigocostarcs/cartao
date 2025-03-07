defmodule Caju.Services.ContasCarteirasService do
  alias Caju.Repositories.ContasCarteirasRepository
  alias Caju.Repositories.TransacoesRepository

  def saldo_suficiente?(carteiras, valor, _mcc, {:ok, mcc_retorno}) do
    valor_decimal = Decimal.new(to_string(valor))

    carteira_correspondente =
      Enum.find(carteiras, fn carteira ->
        campo_permitido =
          case carteira.carteira.tipo_beneficio do
            :food -> mcc_retorno.permite_food
            :meal -> mcc_retorno.permite_meal
            :cash -> mcc_retorno.permite_cash
            _ -> false
          end

        saldo_disponivel = Decimal.sub(carteira.saldo, carteira.saldo_reservado)
        campo_permitido and Decimal.compare(saldo_disponivel, valor_decimal) != :lt
      end)

    if carteira_correspondente do
      {:retorno_mcc, true}
    else
      carteira_cash =
        Enum.find(carteiras, fn carteira ->
          eh_cash = carteira.carteira.tipo_beneficio == :cash
          saldo_disponivel = Decimal.sub(carteira.saldo, carteira.saldo_reservado)
          saldo_suficiente = Decimal.compare(saldo_disponivel, valor_decimal) != :lt

          eh_cash and saldo_suficiente
        end)

      if carteira_cash do
        {:carteira_cash, true}
      else
        {:error, :saldo_insuficiente}
      end
    end
  end

  def saldo_suficiente?(carteiras, valor, _mcc, {:error, :mcc_nao_encontrado}) do
    valor_decimal = Decimal.new(to_string(valor))

    carteira_cash =
      Enum.find(carteiras, fn carteira ->
        eh_cash = carteira.carteira.tipo_beneficio == :cash
        saldo_disponivel = Decimal.sub(carteira.saldo, carteira.saldo_reservado)
        saldo_suficiente = Decimal.compare(saldo_disponivel, valor_decimal) != :lt

        eh_cash and saldo_suficiente
      end)

    if carteira_cash do
      {:carteira_cash, true}
    else
      {:error, :saldo_insuficiente}
    end
  end

  def possui_carteira_cash_e_saldo?(carteiras, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        carteira.carteira.tipo_beneficio == :cash and
          Decimal.compare(carteira.saldo, valor_decimal) != :lt
      end)

    if carteira_valida do
      {:ok, carteira_valida}
    else
      {:error, :saldo_insuficiente}
    end
  end

  def reservar_saldo(conta_carteira, valor) do
    case faz_reserva_de_saldo(conta_carteira, valor) do
      {:ok, _} ->
        {:ok, conta_carteira}

      {:error, _} ->
        consultar_carteira_cash(conta_carteira, valor)
    end
  end

  defp consultar_carteira_cash(conta_carteira, valor) do
    case ContasCarteirasRepository.possui_carteira_cash_e_saldo?(conta_carteira.conta.id, valor) do
      {:ok, carteira} ->
        case faz_reserva_de_saldo(carteira, valor) do
          {:ok, _} ->
            {:ok, carteira}

          {:error, _} ->
            {:error, :saldo_insuficiente}
        end

      {:error, _} ->
        {:error, :saldo_insuficiente}
    end
  end

  defp faz_reserva_de_saldo(conta_carteira, valor) do
    ContasCarteirasRepository.reservar_saldo(conta_carteira, valor)
  end

  def lancar_transacao(conta_carteira, valor, mcc, estabelecimento) do
    case ContasCarteirasRepository.lancar_transacao(conta_carteira, valor, estabelecimento) do
      {:ok, _} ->
        gravar_transacao(conta_carteira, valor, mcc, estabelecimento)

      _ ->
        {:error, :saldo_insuficiente}
    end
  end

  defp gravar_transacao(conta_carteira, valor, mcc, estabelecimento) do
    case TransacoesRepository.lancar_transacao(
           conta_carteira,
           "debito",
           "confirmado",
           valor,
           estabelecimento,
           mcc
         ) do
      {:ok, _} -> {:ok, "00"}
      _ -> {:error, :saldo_insuficiente}
    end
  end
end
