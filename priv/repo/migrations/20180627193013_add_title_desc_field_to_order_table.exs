defmodule Texting.Repo.Migrations.AddTitleDescFieldToOrderTable do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :name, :string
      add :description, :string
    end
  end
end
