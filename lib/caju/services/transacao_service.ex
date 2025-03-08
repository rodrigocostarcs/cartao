defmodule Caju.Services.TransacaoService do
  alias Caju.Repo
  alias Caju.Services.CarteirasService
  alias Caju.ContasServices
  alias Caju.Services.MccsService
  alias Caju.Services.ContasCarteirasService

  def buscar_carteira_por_conta(conta) do
    case CarteirasService.pegar_carteira_por_conta(conta) do
      {:ok, carteiras} ->
        {:ok, carteiras}

      {:error, error} ->
        {:error, error}
    end
  end

  def efetivar_transacao(carteiras, valor, mcc_codigo_original, estabelecimento) do
    Repo.transaction(fn ->
      mcc_resultado = buscar_mccs(mcc_codigo_original, estabelecimento)

      {mcc_codigo_correto, nome_estabelecimento_correto} =
        case mcc_resultado do
          {:ok, mcc} -> {mcc.codigo_mcc, mcc.nome_estabelecimento}
          _ -> {mcc_codigo_original, estabelecimento}
        end

      with {:ok, {mccs, saldo}} <-
             valida_saldo_carteiras(
               mcc_resultado,
               carteiras,
               valor,
               mcc_codigo_original,
               estabelecimento
             ),
           {:ok, carteira} <-
             autorizador_simples(
               {mccs, saldo},
               carteiras,
               valor,
               mcc_codigo_correto,
               nome_estabelecimento_correto
             )
             |> autorizador_com_fallback(
               carteiras,
               valor,
               mcc_codigo_correto,
               nome_estabelecimento_correto
             ),
           {:ok, conta_carteira} <- buscar_conta_carteira(carteiras, carteira),
           {:ok, conta_carteira} <-
             reserva_de_saldo(
               {:ok, conta_carteira},
               carteiras,
               valor,
               mcc_codigo_correto,
               nome_estabelecimento_correto
             ),
           {:ok, codigo} <-
             lancar_transacao(
               {:ok, conta_carteira},
               carteiras,
               valor,
               mcc_codigo_correto,
               nome_estabelecimento_correto
             ) do
        {:ok, codigo}
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  defp buscar_conta_carteira(carteiras, carteira) do
    case Enum.find(carteiras, fn c -> c.carteira_id == carteira.id end) do
      nil -> {:error, :conta_carteira_nao_encontrada}
      conta_carteira -> {:ok, conta_carteira}
    end
  end

  defp autorizador_simples(
         {{:error, _motivo}, false},
         _carteiras,
         _valor,
         _mcc,
         _estabelecimento
       ),
       do: {:error, :mcc_nao_encontrado_e_sem_saldo}

  defp autorizador_simples({{:ok, mccs}, true}, carteiras, _valor, _mcc, _estabelecimento) do
    carteira_valida =
      Enum.find(carteiras, fn carteira ->
        case carteira.carteira.tipo_beneficio do
          :food -> mccs.permite_food
          :meal -> mccs.permite_meal
          :cash -> mccs.permite_cash
          _ -> false
        end
      end)

    if carteira_valida do
      {:ok, carteira_valida.carteira}
    else
      {:error, :mcc_nao_encontrado_e_tem_saldo}
    end
  end

  defp autorizador_simples({carteiras, true}, _carteiras, _valor, _mcc, _estabelecimento) do
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
         valor,
         _mcc,
         _estabelecimento
       ) do
    case ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, valor) do
      {:ok, carteira} ->
        {:ok, carteira.carteira}

      {:error, :saldo_insuficiente} ->
        {:error, :saldo_insuficiente}
    end
  end

  defp autorizador_com_fallback({:ok, carteira}, _carteiras, _valor, _mcc, _estabelecimento),
    do: {:ok, carteira}

  defp buscar_mccs(mcc, estabelecimento) do
    MccsService.buscar_mccs(mcc, estabelecimento)
  end

  defp valida_saldo_carteiras(retorno_mcc, carteiras, valor, mcc, _estabelecimento) do
    case ContasCarteirasService.saldo_suficiente?(carteiras, valor, mcc, retorno_mcc) do
      {:retorno_mcc, true} -> {:ok, {retorno_mcc, true}}
      {:carteira_cash, true} -> {:ok, {carteiras, true}}
      {:error, :saldo_insuficiente} -> {:error, :saldo_insuficiente}
    end
  end

  defp reserva_de_saldo({:ok, carteira}, _carteiras, valor, _mcc, _estabelecimento) do
    ContasCarteirasService.reservar_saldo(carteira, valor)
  end

  defp reserva_de_saldo({:error, code}, _carteiras, _valor, _mcc, _estabelecimento),
    do: {:error, code}

  defp lancar_transacao({:ok, carteira}, _carteiras, valor, mcc_codigo, estabelecimento) do
    ContasCarteirasService.lancar_transacao(carteira, valor, mcc_codigo, estabelecimento)
  end

  defp lancar_transacao(
         {:error, :saldo_insuficiente},
         _carteiras,
         _valor,
         _mcc,
         _estabelecimento
       ),
       do: {:error, :saldo_insuficiente}

  defp lancar_transacao({:error, code}, _carteiras, _valor, _mcc, _estabelecimento),
    do: {:error, code}
end
