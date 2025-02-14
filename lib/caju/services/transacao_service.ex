defmodule Caju.Services.TransacaoService do
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
    buscar_mccs(mcc, merchant)
    |> valida_saldo_carteiras(carteiras, amount, mcc, merchant)
    |> autorizador_simples(carteiras, amount, mcc, merchant)
    |> autorizador_com_fallback(carteiras, amount, mcc, merchant)
    |> reserva_de_saldo(carteiras, amount, mcc, merchant)
    |> lancar_transacao(carteiras, amount, mcc, merchant)
  end

  defp autorizador_simples({false, false}, carteiras, amount, mcc, merchant),
    do: {:error, :mcc_nao_encontrado_e_sem_saldo}

  defp autorizador_simples({true, false}, carteiras, amount, mcc, merchant),
    do: {:error, :mcc_encontrado_e_sem_saldo}

  defp autorizador_simples({false, true}, carteiras, amount, mcc, merchant),
    do: {:error, :mcc_nao_encontrado_e_tem_saldo}

  defp autorizador_simples({true, true}, carteiras, amount, mcc, merchant) do
    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        Enum.any?(carteira.carteira.mccs, fn mcc_associado ->
          mcc_associado.codigo_mcc == mcc
        end)
      end)

    if carteira_valida do
      {:ok, carteira_valida.carteira}
    else
      {:error, :mcc_nao_encontrado_e_tem_saldo}
    end
  end

  defp autorizador_com_fallback(
         {:error, :mcc_nao_encontrado_e_tem_saldo},
         carteiras,
         amount,
         mcc,
         merchant
       ) do
    case ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, amount) do
      {:ok, carteira} ->
        {:ok, carteira}

      {:error, :saldo_insuficiente} ->
        {:error, :saldo_insuficiente}
    end
  end

  defp autorizador_com_fallback(
         {:error, :mcc_encontrado_e_sem_saldo},
         _carteiras,
         _amount,
         _mcc,
         _merchant
       ),
       do: {:error, "51"}

  defp autorizador_com_fallback(
         {:error, :mcc_nao_encontrado_e_sem_saldo},
         _carteiras,
         _amount,
         _mcc,
         _merchant
       ),
       do: {:error, "07"}

  defp autorizador_com_fallback(
         {:error, :mcc_nao_encontrado_e_tem_saldo},
         _carteiras,
         _amount,
         _mcc,
         _merchant
       ),
       do: {:error, "00"}

  defp autorizador_com_fallback({:ok, carteira}, _carteiras, _amount, _mcc, _merchant),
    do: {:ok, carteira}

  defp buscar_mccs(mcc, merchant) do
    MccsService.buscar_mccs(mcc, merchant)
  end

  defp valida_saldo_carteiras(retorno_mcc, carteiras, amount, mcc, merchant) do
    saldo = ContasCarteirasService.saldo_suficiente?(carteiras, amount, mcc)
    {retorno_mcc, saldo}
  end

  defp reserva_de_saldo({:ok, carteira}, carteiras, amount, mcc, merchant) do
    ContasCarteirasService.reservar_saldo(carteira, amount)
  end

  defp reserva_de_saldo({:error, code}, _carteiras, _amount, _mcc, _merchant), do: {:error, code}

  defp lancar_transacao({:ok, carteira}, carteiras, amount, mcc, merchant) do
    ContasCarteirasService.lancar_transacao(carteira, amount, mcc, merchant)
  end

  defp lancar_transacao({:error, code}, _carteiras, _amount, _mcc, _merchant), do: {:error, code}

  defp lancar_transacao({:error, :saldo_insuficiente}, _carteiras, _amount, _mcc, _merchant),
    do: {:error, "51"}
end
