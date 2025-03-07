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

  def pegar_mccs_por_tipo(tipo_beneficio) do
    campo =
      case tipo_beneficio do
        :food -> :permite_food
        :meal -> :permite_meal
        :cash -> :permite_cash
        # Fallback para tipo desconhecido
        _ -> :permite_cash
      end

    query =
      from m in Mccs,
        where: field(m, ^campo) == true

    Repo.all(query)
  end

  def atualizar_mcc(mcc, attrs) do
    mcc
    |> Mccs.changeset(attrs)
    |> Repo.update()
  end

  def criar_mcc(attrs) do
    %Mccs{}
    |> Mccs.changeset(attrs)
    |> Repo.insert()
  end

  def excluir_mcc(id) do
    case Repo.get(Mccs, id) do
      nil -> {:error, :not_found}
      mcc -> Repo.delete(mcc)
    end
  end
end
