defmodule Texting.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string
      add :phone_number, :string
      add :phonebook_id, references(:phonebooks, on_delete: :nothing)
      timestamps()
    end
    create unique_index(:people, [:phone_number, :phonebook_id])
  end
end
