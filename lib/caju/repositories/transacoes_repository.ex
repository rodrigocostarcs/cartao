defmodule Caju.Repositories.TransacoesRepository do
  import Ecto.Query, warn: false
  alias Caju.{Repo, TransacoesCash, TransacoesFood, TransacoesMeal}

  def lancar_transacoes_cash(carteira, tipo, status, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    transacao = %TransacoesCash{
      conta_id: carteira.conta_id,
      tipo: tipo,
      valor: valor_decimal,
      status: status,
      criado_em: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }

    case Repo.insert(transacao) do
      {:ok, transacao} ->
        {:ok, transacao}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def lancar_transacoes_food(carteira, tipo, status, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    transacao = %TransacoesFood{
      conta_id: carteira.conta_id,
      tipo: tipo,
      valor: valor_decimal,
      status: status,
      criado_em: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }

    case Repo.insert(transacao) do
      {:ok, transacao} ->
        {:ok, transacao}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def lancar_transacoes_meal(carteira, tipo, status, valor) do
    valor_decimal = Decimal.new(to_string(valor))

    transacao = %TransacoesMeal{
      conta_id: carteira.conta_id,
      tipo: tipo,
      valor: valor_decimal,
      status: status,
      criado_em: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }

    case Repo.insert(transacao) do
      {:ok, transacao} ->
        {:ok, transacao}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
