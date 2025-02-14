defmodule Caju.Services.CarteirasService do
  alias Caju.{Repositories.ContasCarteirasRepository, ContasServices}

  defmodule Carteira do
    defstruct [:id, :saldo, :conta]
  end

  def get_carteira_by_conta(conta_numero) do
    case pegar_conta_by_numero(conta_numero) do
      {:ok, conta} ->
        carteiras = ContasCarteirasRepository.get_carteiras_by_conta_id(conta.id)
        {:ok, carteiras}

      :no_content ->
        {:error, :conta_nao_encontrada}
    end
  end

  def pegar_conta_by_numero(conta_numero) do
    ContasServices.pegar_conta_by_numero(conta_numero)
  end
end
