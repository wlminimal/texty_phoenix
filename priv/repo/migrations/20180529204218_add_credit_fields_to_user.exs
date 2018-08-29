defmodule Texting.Repo.Migrations.AddCreditFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :credits, :integer
    end
  end
end
