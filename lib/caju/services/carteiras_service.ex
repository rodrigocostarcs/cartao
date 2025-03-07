defmodule Caju.Services.CarteirasService do
  alias Caju.{Repositories.ContasCarteirasRepository, ContasServices}

  defmodule Carteira do
    defstruct [:id, :saldo, :conta]
  end

  def pegar_carteira_por_conta(conta_numero) do
    case pegar_conta_por_numero(conta_numero) do
      {:ok, conta} ->
        carteiras = ContasCarteirasRepository.buscar_carteiras_por_conta_id(conta.id)
        {:ok, carteiras}

      :no_content ->
        {:error, :conta_nao_encontrada}
    end
  end

  def pegar_conta_por_numero(conta_numero) do
    ContasServices.pegar_conta_por_numero(conta_numero)
  end
end
