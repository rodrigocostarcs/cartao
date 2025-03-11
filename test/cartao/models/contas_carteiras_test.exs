defmodule Cartao.ContasCarteirasTest do
  use Cartao.DataCase
  alias Cartao.ContasCarteiras
  alias Cartao.Repo

  setup do
    # Criar dados para teste
    {:ok, conta} =
      Repo.insert(%Cartao.Contas{
        numero_conta: "123456",
        nome_titular: "Teste Unitário"
      })

    {:ok, carteira} =
      Repo.insert(%Cartao.Carteiras{
        tipo_beneficio: :food,
        descricao: "Carteira Alimentação"
      })

    {:ok, %{conta: conta, carteira: carteira}}
  end

  describe "changeset/2" do
    test "validação bem-sucedida com dados válidos", %{conta: conta, carteira: carteira} do
      attrs = %{
        conta_id: conta.id,
        carteira_id: carteira.id,
        saldo: Decimal.new("1000.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true
      }

      changeset = ContasCarteiras.changeset(%ContasCarteiras{}, attrs)
      assert changeset.valid?
    end

    test "validação falha sem campos obrigatórios" do
      changeset = ContasCarteiras.changeset(%ContasCarteiras{}, %{})
      refute changeset.valid?

      errors = errors_on(changeset)
      assert errors[:conta_id]
      assert errors[:carteira_id]
      assert errors[:saldo]
      assert errors[:ativo]
    end
  end
end
