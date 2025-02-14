defmodule CajuWeb.TransacaoController do
  use CajuWeb, :controller
  alias Caju.Services.TransacaoService

  def efetivar_transacao(conn, %{
        "account" => account,
        "amount" => amount,
        "mcc" => mcc,
        "merchant" => merchant
      }) do
    case TransacaoService.buscar_carteira_por_conta(account) do
      {:ok, carteiras} ->
        {:ok, code} = TransacaoService.efetivar_transacao(carteiras, amount, mcc, merchant)

        conn
        |> put_status(:ok)
        |> json(%{code: code})

      {:error, error} ->
        conn
        |> put_status(:ok)
        |> json(%{code: "07"})
    end
  end
end
