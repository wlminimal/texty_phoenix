defmodule Texting.Repo.Migrations.AlterEmailFieldInUser do
  use Ecto.Migration

  def change do
  	execute "CREATE EXTENSION IF NOT EXISTS citext"
  	alter table(:users) do
  		modify :email, :citext
  	end

  	create unique_index(:users, [:email])
  end
end
