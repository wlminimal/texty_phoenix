defmodule Texting.Repo.Migrations.AddEmailFieldToPerson do
  use Ecto.Migration

  def change do
    alter  table(:people) do
      add :email, :string
    end
  end
end
