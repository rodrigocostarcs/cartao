defmodule Caju.Services.EstabelecimentosService do
  alias Caju.Repositories.EstabelecimentosRepository

  def pegar_estabelecimento_por_uuid(uuid) do
    estabelecimento = EstabelecimentosRepository.pegar_estabelecimento_por_uuid(uuid)

    case estabelecimento do
      nil -> :no_content
      _ -> {:ok, estabelecimento}
    end
  end

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
