defmodule Texting.Repo.Migrations.AddPlanFieldToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :plan, :string
  	end
  end
end
