defmodule Caju.Repositories.MccsRepository do
  import Ecto.Query, warn: false
  alias Caju.Repo
  alias Caju.Mccs

  def pegar_mcc_por_codigo(codigo) do
    Repo.get_by(Mccs, codigo_mcc: codigo)
  end

  def pegar_mcc_estabelecimento(estabelecimento) do
    query =
      from m in Mccs,
        where: like(m.nome_estabelecimento, ^"%#{estabelecimento}%")

    Repo.all(query)
  end
end
