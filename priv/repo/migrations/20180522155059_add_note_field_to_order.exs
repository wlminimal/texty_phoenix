defmodule Texting.Repo.Migrations.AddNoteFieldToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :note, :string
    end

    create index(:orders, [:user_id])
  end
end
