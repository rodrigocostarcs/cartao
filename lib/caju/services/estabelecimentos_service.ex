defmodule Caju.Services.EstabelecimentosService do
  alias Caju.Repositories.EstabelecimentosRepository

  def get_estabelecimento_uuid(uuid) do
    estabelecimento = EstabelecimentosRepository.get_estabelecimento_uuid(uuid)

    case estabelecimento do
      nil -> :no_content
      _ -> {:ok, estabelecimento}
    end
  end

  def authenticate(uuid, senha) do
    case EstabelecimentosRepository.get_estabelecimento_uuid(uuid) do
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
