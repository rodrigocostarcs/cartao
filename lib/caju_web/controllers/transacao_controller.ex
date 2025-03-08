defmodule CajuWeb.TransacaoController do
  use CajuWeb, :controller
  alias Caju.Services.TransacaoService

  def efetivar_transacao(conn, %{
        "conta" => conta,
        "valor" => valor,
        "mcc" => mcc,
        "estabelecimento" => estabelecimento
      }) do
    case TransacaoService.buscar_carteira_por_conta(conta) do
      {:ok, carteiras} ->
        code =
          TransacaoService.efetivar_transacao(carteiras, valor, mcc, estabelecimento)
          |> pegar_codigo_transacao()

        conn
        |> put_status(:ok)
        |> json(%{code: code})

      {:error, _error} ->
        conn
        |> put_status(:ok)
        |> json(%{code: "07"})
    end
  end

  defp pegar_codigo_transacao(retorno_transacao) do
    case retorno_transacao do
      {:ok, {:ok, code}} -> code
      {:error, :saldo_insuficiente} -> "51"
    end
  end
end
