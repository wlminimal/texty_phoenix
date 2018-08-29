defmodule Texting.Repo.Migrations.CreateChargeTable do
  use Ecto.Migration

  def change do
    create table :charges do
      add :charge_id, :string
      add :amount, :integer
      add :stripe_id, :string
      add :card, :string
      add :date, :timestamp
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
