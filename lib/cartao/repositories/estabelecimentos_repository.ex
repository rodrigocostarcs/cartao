defmodule Cartao.Repositories.EstabelecimentosRepository do
  import Ecto.Query, warn: false
  alias Cartao.{Estabelecimentos, Repo}

  def pegar_estabelecimento_por_uuid(uuid) do
    Estabelecimentos
    |> where([e], e.uuid == ^uuid)
    |> Repo.one()
  end
end
