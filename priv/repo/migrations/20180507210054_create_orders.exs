defmodule Texting.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string
      add :counts, :string
      add :line_items, {:array, :map}

      timestamps()
    end

  end
end
