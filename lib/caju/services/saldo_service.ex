defmodule Caju.Services.SaldoService do
  alias Caju.ContasServices
  alias Caju.Repositories.SaldoRepository

  @doc """
  Consulta o saldo de uma carteira específica para uma conta.

  ## Parâmetros

    * `conta_numero` - Número da conta
    * `tipo_carteira` - Tipo da carteira ("food", "meal", "cash")

  ## Retorno

    * `{:ok, map}` - Mapa com informações do saldo
    * `{:error, :conta_nao_encontrada}` - Conta não encontrada
    * `{:error, :carteira_nao_encontrada}` - Carteira não encontrada para a conta
  """
  def consultar_saldo(conta_numero, tipo_carteira) do
    # Converter tipo_carteira de string para atom de forma segura
    tipo_atom =
      case tipo_carteira do
        "food" -> :food
        "meal" -> :meal
        "cash" -> :cash
        _ -> :invalid_tipo
      end

    # Verificar se o tipo da carteira é válido
    if tipo_atom == :invalid_tipo do
      {:error, :tipo_carteira_invalido}
    else
      # Buscar a conta pelo número
      case ContasServices.pegar_conta_por_numero(conta_numero) do
        {:ok, conta} ->
          # Utilizar o repository para buscar o saldo
          case SaldoRepository.buscar_saldo_por_conta_e_tipo(conta.id, tipo_atom) do
            nil ->
              {:error, :carteira_nao_encontrada}

            saldo_info ->
              # Formatação dos dados para retorno ao controller
              saldo_formatado = %{
                conta_numero: conta_numero,
                titular: conta.nome_titular,
                tipo_carteira: tipo_carteira,
                saldo: Decimal.to_float(saldo_info.saldo),
                saldo_reservado: Decimal.to_float(saldo_info.saldo_reservado),
                saldo_disponivel: Decimal.to_float(saldo_info.saldo_disponivel)
              }

              {:ok, saldo_formatado}
          end

        :no_content ->
          {:error, :conta_nao_encontrada}
      end
    end
  end
end
