defmodule Caju.Repositories.ContasRepository do
  alias Caju.Repo
  alias Caju.Models.Contas

  def pegar_conta_by_id(id) do
    Repo.get(Contas, id)
  end
end
