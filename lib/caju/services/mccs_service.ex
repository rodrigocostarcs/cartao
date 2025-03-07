defmodule Caju.Services.MccsService do
  alias Caju.Repositories.MccsRepository

  def buscar_mccs(mcc, estabelecimento) do
    case MccsRepository.pegar_mcc_por_codigo(mcc) do
      nil ->
        case MccsRepository.pegar_mcc_estabelecimento(estabelecimento) do
          [] -> {:error, :mcc_nao_encontrado}
          [mcc] -> {:ok, mcc}
          mccs when length(mccs) > 1 -> {:error, :mcc_duplicado}
        end

      mcc ->
        {:ok, mcc}
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
