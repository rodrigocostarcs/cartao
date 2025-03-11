defmodule Cartao.Services.MccsService do
  @moduledoc """
  Serviço responsável por operações relacionadas aos códigos MCC (Merchant Category Code).

  Este módulo implementa a lógica de negócio para buscar e validar códigos MCC,
  que são essenciais para determinar quais tipos de carteira podem ser utilizados
  em determinados estabelecimentos.

  Os MCCs são usados para categorizar estabelecimentos comerciais e determinar
  se uma transação pode ser processada com carteiras do tipo food, meal ou cash.
  """

  alias Cartao.Repositories.MccsRepository

  @doc """
  Busca MCC por código ou nome de estabelecimento.

  Esta função implementa uma lógica de precedência na busca:
  1. Primeiro tenta encontrar MCCs pelo nome do estabelecimento
  2. Se encontrar um ou mais MCCs pelo nome, retorna o primeiro ou principal
  3. Se não encontrar pelo nome, tenta buscar pelo código MCC

  ## Parâmetros

    * `mcc` - Código MCC (ex: "5411")
    * `estabelecimento` - Nome do estabelecimento

  ## Retorno

    * `{:ok, mcc_encontrado}` - MCC encontrado com sucesso
    * `{:error, :mcc_nao_encontrado}` - Quando nenhum MCC é encontrado

  ## Exemplos

      iex> MccsService.buscar_mccs("5411", "Qualquer Nome")
      {:ok, %Mccs{codigo_mcc: "5411", nome_estabelecimento: "Qualquer Nome", ...}}

      iex> MccsService.buscar_mccs("9999", "Restaurante A")
      {:ok, %Mccs{codigo_mcc: "5811", nome_estabelecimento: "Restaurante A", ...}}

      iex> MccsService.buscar_mccs("9999", "Estabelecimento Inexistente")
      {:error, :mcc_nao_encontrado}
  """
  @spec buscar_mccs(String.t(), String.t()) ::
          {:ok, Cartao.Mccs.t()} | {:error, :mcc_nao_encontrado}
  def buscar_mccs(mcc, estabelecimento) do
    # Primeiro tenta buscar pelo nome do estabelecimento (precedência mais alta)
    case MccsRepository.pegar_mcc_estabelecimento(estabelecimento) do
      # Se encontrar exatamente um MCC pelo nome do estabelecimento, retorna-o
      [mcc_encontrado] ->
        {:ok, mcc_encontrado}

      # Se encontrar múltiplos MCCs, pega o primeiro como "principal"
      mccs_lista when length(mccs_lista) > 1 ->
        {:ok, List.first(mccs_lista)}

      # Se não encontrar pelo nome do estabelecimento, tenta pelo código MCC
      [] ->
        case MccsRepository.pegar_mcc_por_codigo(mcc) do
          nil ->
            {:error, :mcc_nao_encontrado}

          mcc_encontrado ->
            # Substitui o nome do estabelecimento pelo nome enviado na requisição
            mcc_modificado = %{mcc_encontrado | nome_estabelecimento: estabelecimento}
            {:ok, mcc_modificado}
        end
    end
  end

  @doc """
  Busca MCCs por tipo de benefício.

  Retorna todos os MCCs que permitem um determinado tipo de carteira.

  ## Parâmetros

    * `tipo_beneficio` - Tipo de benefício como atom (:food, :meal, :cash)

  ## Retorno

    * `{:ok, mccs}` - Lista de MCCs que permitem o tipo específico
    * `{:error, :nenhum_mcc_encontrado}` - Quando nenhum MCC é encontrado para o tipo

  ## Exemplos

      iex> MccsService.buscar_mccs_por_tipo(:food)
      {:ok, [%Mccs{...}, %Mccs{...}]}

      iex> MccsService.buscar_mccs_por_tipo(:invalid)
      {:error, :nenhum_mcc_encontrado}
  """
  @spec buscar_mccs_por_tipo(atom()) ::
          {:ok, list(Cartao.Mccs.t())} | {:error, :nenhum_mcc_encontrado}
  def buscar_mccs_por_tipo(tipo_beneficio) do
    mccs = MccsRepository.pegar_mccs_por_tipo(tipo_beneficio)

    case mccs do
      [] -> {:error, :nenhum_mcc_encontrado}
      mccs -> {:ok, mccs}
    end
  end
end
