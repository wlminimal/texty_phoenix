defmodule Texting.Repo.Migrations.AddStripeTable do
  use Ecto.Migration

  def change do
    create table("stripe") do
      add :customer_id, :string
      add :subscription_id, :string
      add :plan_id, :string
      add :plan_name, :string
      add :user_id, references(:users)

      timestamps()
    end
  end
end
