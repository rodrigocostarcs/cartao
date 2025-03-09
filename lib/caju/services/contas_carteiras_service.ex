defmodule Caju.Services.ContasCarteirasService do
  @moduledoc """
  Serviço responsável por operações nas carteiras associadas às contas.

  Este módulo implementa a lógica central de negócio para gerenciar
  carteiras dos usuários, incluindo:

  - Verificação de saldo suficiente para transações
  - Reserva de saldo para evitar condições de corrida
  - Lançamento de transações e atualização de saldos
  - Tratamento de fallbacks (ex: usar carteira cash quando necessário)

  O mecanismo de reserva de saldo é essencial para garantir a consistência
  em ambientes concorrentes, bloqueando temporariamente o valor da transação
  enquanto ela está sendo processada.
  """

  alias Caju.Repositories.ContasCarteirasRepository
  alias Caju.Repositories.TransacoesRepository

  @doc """
  Verifica se há saldo suficiente nas carteiras para uma transação, considerando o MCC.

  Esta função é central na lógica de decisão para processar uma transação:
  1. Verifica se o MCC é compatível com alguma carteira (food, meal, cash)
  2. Verifica se a carteira compatível tem saldo suficiente
  3. Se não encontrar carteira compatível ou não houver saldo, tenta usar carteira cash

  ## Parâmetros

    * `carteiras` - Lista de carteiras do usuário
    * `valor` - Valor da transação
    * `mcc` - Código MCC do estabelecimento
    * `mcc_retorno` - Resultado da busca do MCC ({:ok, mcc} ou {:error, :mcc_nao_encontrado})

  ## Retorno

    * `{:retorno_mcc, true}` - Quando existe carteira compatível com MCC e com saldo
    * `{:carteira_cash, true}` - Quando não há carteira compatível, mas tem carteira cash com saldo
    * `{:error, :saldo_insuficiente}` - Quando não há saldo suficiente em nenhuma carteira

  ## Exemplos

      iex> ContasCarteirasService.saldo_suficiente?(carteiras, 100.0, "5411", {:ok, mcc_supermercado})
      {:retorno_mcc, true}

      iex> ContasCarteirasService.saldo_suficiente?(carteiras, 5000.0, "5411", {:ok, mcc_supermercado})
      {:error, :saldo_insuficiente}
  """
  @spec saldo_suficiente?(list(), float(), String.t(), {:ok, map()} | {:error, atom()}) ::
          {:retorno_mcc, boolean()}
          | {:carteira_cash, boolean()}
          | {:error, :saldo_insuficiente}
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

  @doc """
  Verifica se existe carteira do tipo cash com saldo suficiente.

  ## Parâmetros

    * `carteiras` - Lista de carteiras do usuário
    * `valor` - Valor da transação

  ## Retorno

    * `{:ok, carteira_valida}` - Quando encontra carteira cash com saldo suficiente
    * `{:error, :saldo_insuficiente}` - Quando não há saldo suficiente

  ## Exemplos

      iex> ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, 100.0)
      {:ok, %ContasCarteiras{...}}
  """
  @spec possui_carteira_cash_e_saldo?(list(), float()) ::
          {:ok, map()} | {:error, :saldo_insuficiente}
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

  @doc """
  Reserva saldo para uma transação em processamento.

  Este é um mecanismo essencial para garantir a consistência em ambiente concorrente.
  Primeiro tenta reservar na carteira informada, se falhar, tenta na carteira cash.

  ## Parâmetros

    * `conta_carteira` - Carteira onde será feita a reserva
    * `valor` - Valor a ser reservado

  ## Retorno

    * `{:ok, conta_carteira}` - Reserva realizada com sucesso
    * `{:error, :saldo_insuficiente}` - Não foi possível reservar o saldo

  ## Exemplos

      iex> ContasCarteirasService.reservar_saldo(conta_carteira, 100.0)
      {:ok, %ContasCarteiras{...}}
  """
  @spec reservar_saldo(map(), float()) :: {:ok, map()} | {:error, :saldo_insuficiente}
  def reservar_saldo(conta_carteira, valor) do
    case faz_reserva_de_saldo(conta_carteira, valor) do
      {:ok, _} ->
        {:ok, conta_carteira}

      {:error, _} ->
        consultar_carteira_cash(conta_carteira, valor)
    end
  end

  @doc false
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

  @doc false
  defp faz_reserva_de_saldo(conta_carteira, valor) do
    ContasCarteirasRepository.reservar_saldo(conta_carteira, valor)
  end

  @doc """
  Lança uma transação, efetivando o débito na carteira e registrando no extrato.

  Esta função realiza a operação final da transação, atualizando o saldo da carteira
  e registrando a transação nos históricos do sistema.

  ## Parâmetros

    * `conta_carteira` - Carteira onde será feito o débito
    * `valor` - Valor a ser debitado
    * `mcc` - Código MCC da transação
    * `estabelecimento` - Nome do estabelecimento

  ## Retorno

    * `{:ok, "00"}` - Transação aprovada com sucesso (código 00)
    * `{:error, :saldo_insuficiente}` - Erro ao efetivar a transação

  ## Exemplos

      iex> ContasCarteirasService.lancar_transacao(conta_carteira, 100.0, "5411", "Supermercado A")
      {:ok, "00"}
  """
  @spec lancar_transacao(map(), float(), String.t(), String.t()) ::
          {:ok, String.t()}
          | {:error, :saldo_insuficiente}
  def lancar_transacao(conta_carteira, valor, mcc, estabelecimento) do
    case ContasCarteirasRepository.lancar_transacao(conta_carteira, valor, estabelecimento) do
      {:ok, _} ->
        gravar_transacao(conta_carteira, valor, mcc, estabelecimento)

      _ ->
        {:error, :saldo_insuficiente}
    end
  end

  @doc false
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
