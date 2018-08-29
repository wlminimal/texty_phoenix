defmodule Texting.Repo.Migrations.AddCheckoutFieldsToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :user_id, references(:users)
      add :message_type, :string
      add :total, :decimal
    end
  end
end
