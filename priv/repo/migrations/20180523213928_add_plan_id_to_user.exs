defmodule Texting.Repo.Migrations.AddPlanIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :plan_id, :string
    end
  end
end
