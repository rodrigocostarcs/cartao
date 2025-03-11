defmodule Cartao.Repositories.TransacoesRepository do
  import Ecto.Query, warn: false
  alias Cartao.{Repo, Transacoes}

  def lancar_transacao(carteira, tipo, status, valor, estabelecimento \\ nil, mcc_codigo \\ nil) do
    valor_decimal = Decimal.new(to_string(valor))

    transacao = %Transacoes{
      conta_id: carteira.conta_id,
      carteira_id: carteira.carteira_id,
      tipo: tipo,
      valor: valor_decimal,
      status: status,
      estabelecimento: estabelecimento,
      mcc_codigo: mcc_codigo,
      criado_em: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }

    case Repo.insert(transacao) do
      {:ok, transacao} ->
        {:ok, transacao}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def listar_transacoes_por_conta(conta_id) do
    query =
      from t in Transacoes,
        where: t.conta_id == ^conta_id,
        order_by: [desc: t.criado_em],
        preload: [:carteira]

    Repo.all(query)
  end

  def listar_transacoes_por_carteira(carteira_id) do
    query =
      from t in Transacoes,
        where: t.carteira_id == ^carteira_id,
        order_by: [desc: t.criado_em]

    Repo.all(query)
  end
end
