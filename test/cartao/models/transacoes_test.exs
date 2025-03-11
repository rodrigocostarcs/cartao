defmodule Cartao.TransacoesTest do
  use Cartao.DataCase
  alias Cartao.Transacoes

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
        tipo: "debito",
        valor: Decimal.new("100.00"),
        status: "confirmado",
        estabelecimento: "Supermercado Teste",
        mcc_codigo: "5411"
      }

      changeset = Transacoes.changeset(%Transacoes{}, attrs)
      assert changeset.valid?
    end

    test "validação falha com valor negativo", %{conta: conta, carteira: carteira} do
      attrs = %{
        conta_id: conta.id,
        carteira_id: carteira.id,
        tipo: "debito",
        valor: Decimal.new("-10.00"),
        status: "confirmado"
      }

      changeset = Transacoes.changeset(%Transacoes{}, attrs)
      refute changeset.valid?
      assert %{valor: ["must be greater than 0"]} = errors_on(changeset)
    end

    test "validação falha com tipo inválido", %{conta: conta, carteira: carteira} do
      attrs = %{
        conta_id: conta.id,
        carteira_id: carteira.id,
        tipo: "tipo_invalido",
        valor: Decimal.new("100.00"),
        status: "confirmado"
      }

      changeset = Transacoes.changeset(%Transacoes{}, attrs)
      refute changeset.valid?
      assert %{tipo: ["is invalid"]} = errors_on(changeset)
    end

    test "validação falha com status inválido", %{conta: conta, carteira: carteira} do
      attrs = %{
        conta_id: conta.id,
        carteira_id: carteira.id,
        tipo: "debito",
        valor: Decimal.new("100.00"),
        status: "status_invalido"
      }

      changeset = Transacoes.changeset(%Transacoes{}, attrs)
      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "validação falha sem campos obrigatórios" do
      changeset = Transacoes.changeset(%Transacoes{}, %{})
      refute changeset.valid?

      errors = errors_on(changeset)
      assert errors[:conta_id]
      assert errors[:carteira_id]
      assert errors[:tipo]
      assert errors[:valor]
      assert errors[:status]
    end
  end
end
