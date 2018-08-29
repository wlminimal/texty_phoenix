defmodule Texting.Repo.Migrations.AddDefaultCreditFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :credits, :integer, default: 0
    end
  end
end
