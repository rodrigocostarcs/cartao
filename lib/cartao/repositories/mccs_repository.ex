defmodule Cartao.Repositories.MccsRepository do
  import Ecto.Query, warn: false
  alias Cartao.Repo
  alias Cartao.Mccs

  def pegar_mcc_por_codigo(codigo) do
    # Buscar todos os MCCs com o código fornecido
    query = from m in Mccs, where: m.codigo_mcc == ^codigo

    # Pegar o primeiro resultado da lista (se houver)
    case Repo.all(query) do
      [] -> nil
      [first | _rest] -> first
      mccs when is_list(mccs) -> List.first(mccs)
    end
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
