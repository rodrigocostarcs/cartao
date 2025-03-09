defmodule Caju.Services.SaldoService do
  @moduledoc """
  Serviço responsável pela consulta de saldos nas carteiras dos usuários.

  Este módulo implementa a lógica de negócio para recuperar informações
  de saldo das carteiras dos usuários, trabalhando como uma camada
  intermediária entre os controllers e os repositories.

  Responsabilidades:
  - Validar o tipo de carteira solicitado
  - Buscar informações de conta e carteira
  - Formatar os dados de saldo para apresentação
  - Tratar casos de erro (conta não encontrada, carteira não encontrada, tipo inválido)
  """

  alias Caju.ContasServices
  alias Caju.Repositories.SaldoRepository

  @doc """
  Consulta o saldo de uma carteira específica para uma conta.

  ## Parâmetros

    * `conta_numero` - Número da conta do usuário
    * `tipo_carteira` - Tipo da carteira ("food", "meal", "cash")

  ## Retorno

    * `{:ok, map}` - Mapa com informações do saldo, incluindo:
       - `conta_numero` - Número da conta
       - `titular` - Nome do titular da conta
       - `tipo_carteira` - Tipo da carteira consultada
       - `saldo` - Saldo total da carteira
       - `saldo_reservado` - Saldo reservado para transações em processamento
       - `saldo_disponivel` - Saldo disponível para uso (saldo - saldo_reservado)
    * `{:error, :conta_nao_encontrada}` - Quando a conta informada não existe
    * `{:error, :carteira_nao_encontrada}` - Quando a conta existe mas não possui a carteira solicitada
    * `{:error, :tipo_carteira_invalido}` - Quando o tipo de carteira informado não é válido

  ## Exemplos

      iex> SaldoService.consultar_saldo("123456", "food")
      {:ok, %{conta_numero: "123456", titular: "João Silva", tipo_carteira: "food", saldo: 1000.0, saldo_reservado: 0.0, saldo_disponivel: 1000.0}}

      iex> SaldoService.consultar_saldo("789012", "invalid")
      {:error, :tipo_carteira_invalido}
  """
  @spec consultar_saldo(String.t(), String.t()) ::
          {:ok, map()}
          | {:error, :conta_nao_encontrada}
          | {:error, :carteira_nao_encontrada}
          | {:error, :tipo_carteira_invalido}
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
