defmodule Texting.Repo.Migrations.RemoveNoteAddMessageFieldToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :note
      add :message, :text
    end
  end
end
