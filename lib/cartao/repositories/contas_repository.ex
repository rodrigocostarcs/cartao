defmodule Cartao.Repositories.ContasRepository do
  alias Cartao.Repo
  alias Cartao.Contas

  def pegar_conta_por_id(id) do
    Repo.get(Contas, id)
  end

  def pegar_conta_por_numero(numero) do
    Repo.get_by(Contas, numero_conta: numero)
  end
end
