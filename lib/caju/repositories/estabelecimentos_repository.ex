defmodule Caju.Repositories.EstabelecimentosRepository do
  import Ecto.Query, warn: false
  alias Caju.{Estabelecimentos, Repo}

  def get_estabelecimento_uuid(uuid) do
    Estabelecimentos
    |> where([e], e.uuid == ^uuid)
    |> Repo.one()
  end
end
