defmodule Cartao.ContasServices do
  @moduledoc """
  Serviço responsável por operações relacionadas às contas dos usuários.

  Este módulo fornece funções para recuperar e gerenciar as contas dos usuários,
  servindo como camada de abstração entre os controllers e o acesso direto aos dados.

  Principais responsabilidades:
  - Recuperar informações de contas por ID ou número da conta
  - Tratar casos onde a conta não é encontrada
  - Formatar os dados de contas para uso pelas camadas superiores
  """

  alias Cartao.Repositories.ContasRepository

  @doc """
  Recupera uma conta pelo ID.

  ## Parâmetros

    * `id` - ID da conta no banco de dados

  ## Retorno

    * `{:ok, conta}` - Conta encontrada
    * `:no_content` - Conta não encontrada

  ## Exemplos

      iex> ContasServices.pegar_conta_por_id(1)
      {:ok, %Contas{...}}

      iex> ContasServices.pegar_conta_por_id(999)
      :no_content
  """
  @spec pegar_conta_por_id(integer()) :: {:ok, Cartao.Contas.t()} | :no_content
  def pegar_conta_por_id(id) do
    conta = ContasRepository.pegar_conta_por_id(id)

    case conta do
      nil -> :no_content
      _ -> {:ok, conta}
    end
  end

  @doc """
  Recupera uma conta pelo número da conta.

  ## Parâmetros

    * `numero` - Número da conta (ex: "123456")

  ## Retorno

    * `{:ok, conta}` - Conta encontrada
    * `:no_content` - Conta não encontrada

  ## Exemplos

      iex> ContasServices.pegar_conta_por_numero("123456")
      {:ok, %Contas{...}}

      iex> ContasServices.pegar_conta_por_numero("999999")
      :no_content
  """
  @spec pegar_conta_por_numero(String.t()) :: {:ok, Cartao.Contas.t()} | :no_content
  def pegar_conta_por_numero(numero) do
    conta = ContasRepository.pegar_conta_por_numero(numero)

    case conta do
      nil -> :no_content
      _ -> {:ok, conta}
    end
  end
end
