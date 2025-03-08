defmodule Caju.Seeds.SeedData do
  alias Caju.Repo
  alias Caju.Contas
  alias Caju.Carteiras
  alias Caju.ContasCarteiras
  alias Caju.Mccs
  alias Caju.Estabelecimentos

  def insert_seed_data do
    # Limpar todas as tabelas antes de inserir
    Repo.delete_all(ContasCarteiras)
    Repo.delete_all(Contas)
    Repo.delete_all(Carteiras)
    Repo.delete_all(Mccs)
    Repo.delete_all(Estabelecimentos)

    # Inserir contas com números de conta únicos
    {:ok, conta1} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "123456",
        nome_titular: "João Silva"
      })
      |> Repo.insert()

    {:ok, conta2} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "654321",
        nome_titular: "Maria Oliveira"
      })
      |> Repo.insert()

    {:ok, conta3} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "789012",
        nome_titular: "Rodrigo Costa"
      })
      |> Repo.insert()

    # Inserir carteiras
    {:ok, food_wallet} =
      %Carteiras{}
      |> Carteiras.changeset(%{tipo_beneficio: :food, descricao: "Benefício Alimentação"})
      |> Repo.insert()

    {:ok, meal_wallet} =
      %Carteiras{}
      |> Carteiras.changeset(%{tipo_beneficio: :meal, descricao: "Benefício Refeição"})
      |> Repo.insert()

    {:ok, cash_wallet} =
      %Carteiras{}
      |> Carteiras.changeset(%{tipo_beneficio: :cash, descricao: "Benefício Dinheiro"})
      |> Repo.insert()

    # Inserir contas_carteiras
    %ContasCarteiras{}
    |> ContasCarteiras.changeset(%{
      conta_id: conta1.id,
      carteira_id: food_wallet.id,
      saldo: Decimal.new("1000.00"),
      ativo: true
    })
    |> Repo.insert()

    %ContasCarteiras{}
    |> ContasCarteiras.changeset(%{
      conta_id: conta2.id,
      carteira_id: meal_wallet.id,
      saldo: Decimal.new("2000.00"),
      ativo: true
    })
    |> Repo.insert()

    %ContasCarteiras{}
    |> ContasCarteiras.changeset(%{
      conta_id: conta3.id,
      carteira_id: meal_wallet.id,
      saldo: Decimal.new("3000.00"),
      ativo: true
    })
    |> Repo.insert()

    %ContasCarteiras{}
    |> ContasCarteiras.changeset(%{
      conta_id: conta3.id,
      carteira_id: cash_wallet.id,
      saldo: Decimal.new("3000.00"),
      ativo: true
    })
    |> Repo.insert()

    # Resto do código permanece o mesmo
    %Mccs{}
    |> Mccs.changeset(%{
      codigo_mcc: "5411",
      nome_estabelecimento: "Supermercado A",
      permite_food: true,
      permite_meal: false,
      permite_cash: false
    })
    |> Repo.insert()

    %Mccs{}
    |> Mccs.changeset(%{
      codigo_mcc: "5412",
      nome_estabelecimento: "Supermercado B",
      permite_food: true,
      permite_meal: false,
      permite_cash: false
    })
    |> Repo.insert()

    %Mccs{}
    |> Mccs.changeset(%{
      codigo_mcc: "5811",
      nome_estabelecimento: "Restaurante A",
      permite_food: false,
      permite_meal: true,
      permite_cash: false
    })
    |> Repo.insert()

    %Mccs{}
    |> Mccs.changeset(%{
      codigo_mcc: "5812",
      nome_estabelecimento: "Restaurante B",
      permite_food: false,
      permite_meal: true,
      permite_cash: false
    })
    |> Repo.insert()

    %Mccs{}
    |> Mccs.changeset(%{
      codigo_mcc: "5999",
      nome_estabelecimento: "Loja de Conveniência",
      permite_food: false,
      permite_meal: false,
      permite_cash: true
    })
    |> Repo.insert()

    # Inserir estabelecimentos
    %Estabelecimentos{}
    |> Estabelecimentos.changeset(%{
      uuid: "fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea",
      nome_estabelecimento: "Estabelecimento Exemplo",
      senha: "senha_secreta"
    })
    |> Repo.insert()
  end
end

# Executar a inserção de dados de teste
case Mix.env() do
  :test ->
    IO.puts("Seeds de teste podem ser carregados no setup do teste")

  :dev ->
    Caju.Seeds.SeedData.insert_seed_data()
    IO.puts("Seeds de desenvolvimento inseridos com sucesso!")

  _ ->
    IO.puts("Não é possível rodar seeds para: #{Mix.env()}")
end
