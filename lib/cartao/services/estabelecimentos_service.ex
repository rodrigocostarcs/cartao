defmodule Cartao.Services.EstabelecimentosService do
  @moduledoc """
  Serviço responsável por operações relacionadas aos estabelecimentos comerciais.

  Este módulo gerencia a autenticação e recuperação de dados dos estabelecimentos
  comerciais que utilizam a API para processar transações.

  Principais responsabilidades:
  - Autenticar estabelecimentos usando credenciais
  - Recuperar informações de estabelecimentos por UUID
  - Validar credenciais para geração de tokens JWT
  """

  alias Cartao.Repositories.EstabelecimentosRepository

  @doc """
  Recupera um estabelecimento pelo UUID.

  ## Parâmetros

    * `uuid` - UUID do estabelecimento

  ## Retorno

    * `{:ok, estabelecimento}` - Estabelecimento encontrado
    * `:no_content` - Estabelecimento não encontrado

  ## Exemplos

      iex> EstabelecimentosService.pegar_estabelecimento_por_uuid("fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea")
      {:ok, %Estabelecimentos{...}}

      iex> EstabelecimentosService.pegar_estabelecimento_por_uuid("uuid-inexistente")
      :no_content
  """
  @spec pegar_estabelecimento_por_uuid(String.t()) ::
          {:ok, Cartao.Estabelecimentos.t()} | :no_content
  def pegar_estabelecimento_por_uuid(uuid) do
    estabelecimento = EstabelecimentosRepository.pegar_estabelecimento_por_uuid(uuid)

    case estabelecimento do
      nil -> :no_content
      _ -> {:ok, estabelecimento}
    end
  end

  @doc """
  Autentica um estabelecimento utilizando UUID e senha.

  Esta função é utilizada no processo de login para validar as credenciais
  de um estabelecimento e permitir a geração de um token JWT.

  ## Parâmetros

    * `uuid` - UUID do estabelecimento
    * `senha` - Senha do estabelecimento (não criptografada)

  ## Retorno

    * `{:ok, estabelecimento}` - Autenticação bem-sucedida
    * `:error` - Credenciais inválidas

  ## Exemplos

      iex> EstabelecimentosService.autenticar("fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea", "senha_secreta")
      {:ok, %Estabelecimentos{...}}

      iex> EstabelecimentosService.autenticar("fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea", "senha_errada")
      :error
  """
  @spec autenticar(String.t(), String.t()) :: {:ok, Cartao.Estabelecimentos.t()} | :error
  def autenticar(uuid, senha) do
    case EstabelecimentosRepository.pegar_estabelecimento_por_uuid(uuid) do
      nil ->
        :error

      estabelecimento ->
        if Pbkdf2.verify_pass(senha, estabelecimento.senha_hash) do
          {:ok, estabelecimento}
        else
          :error
        end
    end
  end
end
