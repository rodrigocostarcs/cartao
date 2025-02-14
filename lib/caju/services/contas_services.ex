defmodule Caju.ContasServices do
  alias Caju.Repositories.ContasRepository

  def pegar_conta_by_id(id) do
    conta = ContasRepository.pegar_conta_by_id(id)

    case conta do
      nil -> :no_content
      _ -> {:ok, conta}
    end
  end

  def pegar_conta_by_numero(numero) do
    conta = ContasRepository.pegar_conta_by_numero(numero)

    case conta do
      nil -> :no_content
      _ -> {:ok, conta}
    end
  end
end
