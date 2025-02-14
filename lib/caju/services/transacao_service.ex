defmodule Caju.Services.TransacaoService do
  alias Caju.Repo
  alias Caju.Services.CarteirasService
  alias Caju.ContasServices
  alias Caju.Services.MccsService
  alias Caju.Services.ContasCarteirasService

  def buscar_carteira_por_conta(account) do
    case CarteirasService.get_carteira_by_conta(account) do
      {:ok, carteiras} ->
        {:ok, carteiras}

      {:error, error} ->
        {:error, error}
    end
  end

  def efetivar_transacao(carteiras, amount, mcc, merchant) do
    Repo.transaction(fn ->
      mccs = buscar_mccs(mcc, merchant)

      with {:ok, {mccs, saldo}} <-
             valida_saldo_carteiras(mccs, carteiras, amount, mcc, merchant),
           {:ok, carteira} <-
             autorizador_simples({mccs, saldo}, carteiras, amount, mcc, merchant)
             |> autorizador_com_fallback(carteiras, amount, mcc, merchant),
           {:ok, conta_carteira} <- buscar_conta_carteira(carteiras, carteira),
           {:ok, conta_carteira} <-
             reserva_de_saldo({:ok, conta_carteira}, carteiras, amount, mcc, merchant),
           {:ok, conta_carteira} <-
             lancar_transacao({:ok, conta_carteira}, carteiras, amount, mcc, merchant) do
        {:ok, conta_carteira}
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  defp buscar_conta_carteira(carteiras, carteira) do
    case Enum.find(carteiras, fn c -> c.carteira_id == carteira.id_carteira end) do
      nil -> {:error, :conta_carteira_nao_encontrada}
      conta_carteira -> {:ok, conta_carteira}
    end
  end

  defp autorizador_simples({_mccs, false}, _carteiras, _amount, _mcc, _merchant),
    do: {:error, :mcc_nao_encontrado_e_sem_saldo}

  defp autorizador_simples({{:ok, mccs}, true}, carteiras, _amount, mcc, merchant) do
    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        Enum.any?(carteira.carteira.mccs, fn mcc_associado ->
          mcc_associado.codigo_mcc == mcc or mcc_associado.nome_estabelecimento == merchant
        end)
      end)

    if carteira_valida do
      {:ok, carteira_valida.carteira}
    else
      {:error, :mcc_nao_encontrado_e_tem_saldo}
    end
  end

  defp autorizador_simples({carteiras, true}, _carteiras, _amount, _mcc, _merchant) do
    carteira_cash =
      Enum.find(carteiras, fn carteira ->
        carteira.carteira.tipo_beneficio == :cash
      end)

    if carteira_cash do
      {:ok, carteira_cash.carteira}
    else
      {:error, :saldo_insuficiente}
    end
  end

  defp autorizador_com_fallback(
         {:error, :mcc_nao_encontrado_e_tem_saldo},
         carteiras,
         amount,
         _mcc,
         _merchant
       ) do
    case ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, amount) do
      {:ok, carteira} ->
        {:ok, carteira.carteira}

      {:error, :saldo_insuficiente} ->
        {:error, :saldo_insuficiente}
    end
  end

  defp autorizador_com_fallback({:ok, carteira}, _carteiras, _amount, _mcc, _merchant),
    do: {:ok, carteira}

  defp buscar_mccs(mcc, merchant) do
    MccsService.buscar_mccs(mcc, merchant)
  end

  defp valida_saldo_carteiras(retorno_mcc, carteiras, amount, mcc, _merchant) do
    case ContasCarteirasService.saldo_suficiente?(carteiras, amount, mcc, retorno_mcc) do
      {:retorno_mcc, true} -> {:ok, {retorno_mcc, true}}
      {:carteira_cash, true} -> {:ok, {carteiras, true}}
      {:error, :saldo_insuficiente} -> {:error, :saldo_insuficiente}
    end
  end

  defp reserva_de_saldo({:ok, carteira}, _carteiras, amount, _mcc, _merchant) do
    ContasCarteirasService.reservar_saldo(carteira, amount)
  end

  defp reserva_de_saldo({:error, code}, _carteiras, _amount, _mcc, _merchant), do: {:error, code}

  defp lancar_transacao({:ok, carteira}, _carteiras, amount, _mcc, merchant) do
    ContasCarteirasService.lancar_transacao(carteira, amount, _mcc, merchant)
  end

  defp lancar_transacao({:error, code}, _carteiras, _amount, _mcc, _merchant),
    do: {:error, code}

  defp lancar_transacao({:error, :saldo_insuficiente}, _carteiras, _amount, _mcc, _merchant),
    do: {:error, :saldo_insuficiente}
end
