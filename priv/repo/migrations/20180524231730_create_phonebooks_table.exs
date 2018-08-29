defmodule Texting.Repo.Migrations.CreatePhonebooks do
  use Ecto.Migration

  def change do
    create table(:phonebooks) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create unique_index(:phonebooks, [:name, :user_id])
  end
end
