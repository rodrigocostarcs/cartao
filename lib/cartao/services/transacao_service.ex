defmodule Cartao.Services.TransacaoService do
  @moduledoc """
  Serviço responsável pelo processamento de transações financeiras.

  Este módulo implementa a lógica principal do sistema Cartao, gerenciando
  o fluxo completo de processamento de transações, incluindo:

  - Verificação de carteiras associadas a uma conta
  - Validação de MCC (Merchant Category Code)
  - Seleção da carteira apropriada para a transação
  - Reserva de saldo para evitar condições de corrida
  - Efetivação de débito e registro da transação
  - Tratamento de casos de erro (saldo insuficiente, conta não encontrada)

  Toda a lógica é encapsulada em uma transaction do Ecto para garantir
  atomicidade e consistência das operações.
  """

  alias Cartao.Repo
  alias Cartao.Services.CarteirasService
  alias Cartao.Services.MccsService
  alias Cartao.Services.ContasCarteirasService

  @doc """
  Busca as carteiras associadas a uma conta específica.

  ## Parâmetros

    * `conta` - Número da conta do usuário

  ## Retorno

    * `{:ok, carteiras}` - Lista de carteiras associadas à conta
    * `{:error, error}` - Erro ao buscar carteiras (ex: conta não encontrada)

  ## Exemplos

      iex> TransacaoService.buscar_carteira_por_conta("123456")
      {:ok, [%ContasCarteiras{...}, %ContasCarteiras{...}]}

      iex> TransacaoService.buscar_carteira_por_conta("999999")
      {:error, :conta_nao_encontrada}
  """
  @spec buscar_carteira_por_conta(String.t()) :: {:ok, list()} | {:error, atom()}
  def buscar_carteira_por_conta(conta) do
    case CarteirasService.pegar_carteira_por_conta(conta) do
      {:ok, carteiras} ->
        {:ok, carteiras}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Processa uma transação financeira completa.

  Esta função representa o fluxo principal do sistema, realizando todos os passos
  necessários para efetivar uma transação financeira, incluindo:

  1. Busca do MCC para determinar qual carteira usar
  2. Validação de saldo na carteira apropriada
  3. Reserva de saldo para evitar condições de corrida
  4. Efetivação do débito na carteira
  5. Registro da transação e do extrato

  Todas as operações são encapsuladas em uma transaction do Ecto
  para garantir atomicidade.

  ## Parâmetros

    * `carteiras` - Lista de carteiras associadas à conta
    * `valor` - Valor da transação
    * `mcc_codigo_original` - Código MCC do estabelecimento
    * `estabelecimento` - Nome do estabelecimento

  ## Retorno

    * `{:ok, {:ok, "00"}}` - Transação aprovada com sucesso
    * `{:error, :saldo_insuficiente}` - Saldo insuficiente para a transação
    * `{:error, reason}` - Outros erros durante o processamento

  ## Exemplos

      iex> TransacaoService.efetivar_transacao(carteiras, 100.00, "5411", "Supermercado A")
      {:ok, {:ok, "00"}}

      iex> TransacaoService.efetivar_transacao(carteiras, 5000.00, "5411", "Supermercado A")
      {:error, :saldo_insuficiente}
  """
  @spec efetivar_transacao(list(), float(), String.t(), String.t()) ::
          {:ok, {:ok, String.t()}}
          | {:error, atom()}
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

  # Funções privadas auxiliares para o processamento da transação

  @doc false
  defp buscar_conta_carteira(carteiras, carteira) do
    case Enum.find(carteiras, fn c -> c.carteira_id == carteira.id end) do
      nil -> {:error, :conta_carteira_nao_encontrada}
      conta_carteira -> {:ok, conta_carteira}
    end
  end

  @doc false
  defp autorizador_simples(
         {{:error, _motivo}, _saldo},
         _carteiras,
         _valor,
         _mcc,
         _estabelecimento
       ) do
    {:error, :mcc_nao_encontrado_e_sem_saldo}
  end

  @doc false
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

  @doc false
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

  @doc false
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

  @doc false
  defp autorizador_com_fallback({:ok, carteira}, _carteiras, _valor, _mcc, _estabelecimento),
    do: {:ok, carteira}

  @doc false
  defp autorizador_com_fallback({:error, reason}, _carteiras, _valor, _mcc, _estabelecimento),
    do: {:error, reason}

  @doc false
  defp buscar_mccs(mcc, estabelecimento) do
    MccsService.buscar_mccs(mcc, estabelecimento)
  end

  @doc false
  defp valida_saldo_carteiras(retorno_mcc, carteiras, valor, mcc, _estabelecimento) do
    case ContasCarteirasService.saldo_suficiente?(carteiras, valor, mcc, retorno_mcc) do
      {:retorno_mcc, true} -> {:ok, {retorno_mcc, true}}
      {:carteira_cash, true} -> {:ok, {carteiras, true}}
      {:error, :saldo_insuficiente} -> {:error, :saldo_insuficiente}
    end
  end

  @doc false
  defp reserva_de_saldo({:ok, carteira}, _carteiras, valor, _mcc, _estabelecimento) do
    ContasCarteirasService.reservar_saldo(carteira, valor)
  end

  @doc false
  defp lancar_transacao({:ok, carteira}, _carteiras, valor, mcc_codigo, estabelecimento) do
    ContasCarteirasService.lancar_transacao(carteira, valor, mcc_codigo, estabelecimento)
  end
end
