defmodule Caju.Services.MccsService do
  alias Caju.Repositories.MccsRepository

  @doc """
  Busca MCC por código ou nome de estabelecimento.
  O nome do estabelecimento tem precedência sobre o código MCC.
  """
  def buscar_mccs(mcc, estabelecimento) do
    # Primeiro tenta buscar pelo nome do estabelecimento (precedência mais alta)
    case MccsRepository.pegar_mcc_estabelecimento(estabelecimento) do
      # Se encontrar exatamente um MCC pelo nome do estabelecimento, retorna-o
      [mcc_encontrado] ->
        {:ok, mcc_encontrado}

      # Se encontrar múltiplos MCCs pelo nome do estabelecimento pega o primeiro como "principal".
      [mcc_principal | _outros] when length([mcc_principal | _outros]) > 1 ->
        {:ok, mcc_principal}

      # Se não encontrar pelo nome do estabelecimento, tenta pelo código MCC
      [] ->
        case MccsRepository.pegar_mcc_por_codigo(mcc) do
          nil -> {:error, :mcc_nao_encontrado}
          mcc_encontrado -> {:ok, mcc_encontrado}
        end
    end
  end

  def buscar_mccs_por_tipo(tipo_beneficio) do
    mccs = MccsRepository.pegar_mccs_por_tipo(tipo_beneficio)

    case mccs do
      [] -> {:error, :nenhum_mcc_encontrado}
      mccs -> {:ok, mccs}
    end
  end

  def criar_ou_atualizar_mcc(attrs) do
    case MccsRepository.pegar_mcc_por_codigo(attrs.codigo_mcc) do
      nil -> MccsRepository.criar_mcc(attrs)
      mcc -> MccsRepository.atualizar_mcc(mcc, attrs)
    end
  end

  def excluir_mcc(id) do
    MccsRepository.excluir_mcc(id)
  end
end
