defmodule Caju.Services.CarteirasService do
  @moduledoc """
  Serviço responsável pelas operações relacionadas às carteiras dos usuários.

  Este módulo fornece funções para gerenciar e recuperar informações
  sobre as carteiras associadas às contas dos usuários, servindo como
  interface entre os controllers e os repositories relacionados.

  Principais responsabilidades:
  - Recuperar carteiras associadas a uma conta específica
  - Fornecer informações sobre tipos de carteira (food, meal, cash)
  - Abstrair o acesso aos dados de contas e carteiras
  """

  alias Caju.Repositories.ContasCarteirasRepository
  alias Caju.ContasServices

  defmodule Carteira do
    @moduledoc """
    Estrutura para representar uma carteira simplificada.
    """
    defstruct [:id, :saldo, :conta]
  end

  @doc """
  Recupera todas as carteiras associadas a uma conta específica.

  ## Parâmetros

    * `conta_numero` - Número da conta do usuário

  ## Retorno

    * `{:ok, carteiras}` - Lista de carteiras associadas à conta
    * `{:error, :conta_nao_encontrada}` - Quando a conta informada não existe

  ## Exemplos

      iex> CarteirasService.pegar_carteira_por_conta("123456")
      {:ok, [%ContasCarteiras{...}, %ContasCarteiras{...}]}

      iex> CarteirasService.pegar_carteira_por_conta("999999")
      {:error, :conta_nao_encontrada}
  """
  @spec pegar_carteira_por_conta(String.t()) :: {:ok, list()} | {:error, :conta_nao_encontrada}
  def pegar_carteira_por_conta(conta_numero) do
    case pegar_conta_por_numero(conta_numero) do
      {:ok, conta} ->
        carteiras = ContasCarteirasRepository.buscar_carteiras_por_conta_id(conta.id)
        {:ok, carteiras}

      :no_content ->
        {:error, :conta_nao_encontrada}
    end
  end

  @doc """
  Recupera uma conta pelo número.

  ## Parâmetros

    * `conta_numero` - Número da conta do usuário

  ## Retorno

    * `{:ok, conta}` - Conta encontrada
    * `:no_content` - Conta não encontrada

  ## Exemplos

      iex> CarteirasService.pegar_conta_por_numero("123456")
      {:ok, %Contas{...}}

      iex> CarteirasService.pegar_conta_por_numero("999999")
      :no_content
  """
  @spec pegar_conta_por_numero(String.t()) :: {:ok, Caju.Contas.t()} | :no_content
  def pegar_conta_por_numero(conta_numero) do
    ContasServices.pegar_conta_por_numero(conta_numero)
  end
end
