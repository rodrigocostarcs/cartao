defmodule Caju.Repositories.SaldoRepositoryTest do
  use Caju.DataCase
  alias Caju.Repositories.SaldoRepository
  alias Caju.{Contas, Carteiras, ContasCarteiras, Repo}

  setup do
    # Limpar dados existentes
    Repo.delete_all(ContasCarteiras)
    Repo.delete_all(Carteiras)
    Repo.delete_all(Contas)

    # Criar conta de teste
    {:ok, conta} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "444444",
        nome_titular: "Teste Repository"
      })
      |> Repo.insert()

    # Criar carteiras
    {:ok, food_carteira} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :food,
        descricao: "Carteira Alimentação Repository"
      })
      |> Repo.insert()

    {:ok, cash_carteira} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :cash,
        descricao: "Carteira Dinheiro Repository"
      })
      |> Repo.insert()

    # Associar carteiras à conta
    {:ok, conta_carteira_food} =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: food_carteira.id,
        saldo: Decimal.new("3000.00"),
        saldo_reservado: Decimal.new("500.00"),
        ativo: true
      })
      |> Repo.insert()

    {:ok, conta_carteira_cash} =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: cash_carteira.id,
        saldo: Decimal.new("1500.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true
      })
      |> Repo.insert()

    {:ok,
     conta: conta,
     food_carteira: food_carteira,
     cash_carteira: cash_carteira,
     conta_carteira_food: conta_carteira_food,
     conta_carteira_cash: conta_carteira_cash}
  end

  describe "buscar_saldo_por_conta_e_tipo/2" do
    test "retorna detalhes corretos do saldo para carteira food", %{conta: conta} do
      saldo_info = SaldoRepository.buscar_saldo_por_conta_e_tipo(conta.id, :food)

      assert saldo_info != nil
      assert Decimal.equal?(saldo_info.saldo, Decimal.new("3000.00"))
      assert Decimal.equal?(saldo_info.saldo_reservado, Decimal.new("500.00"))
      assert Decimal.equal?(saldo_info.saldo_disponivel, Decimal.new("2500.00"))
    end

    test "retorna detalhes corretos do saldo para carteira cash", %{conta: conta} do
      saldo_info = SaldoRepository.buscar_saldo_por_conta_e_tipo(conta.id, :cash)

      assert saldo_info != nil
      assert Decimal.equal?(saldo_info.saldo, Decimal.new("1500.00"))
      assert Decimal.equal?(saldo_info.saldo_reservado, Decimal.new("0.00"))
      assert Decimal.equal?(saldo_info.saldo_disponivel, Decimal.new("1500.00"))
    end

    test "retorna nil para carteira inexistente", %{conta: conta} do
      result = SaldoRepository.buscar_saldo_por_conta_e_tipo(conta.id, :meal)
      assert result == nil
    end

    test "retorna nil para conta inexistente" do
      result = SaldoRepository.buscar_saldo_por_conta_e_tipo(9999, :food)
      assert result == nil
    end
  end
end
