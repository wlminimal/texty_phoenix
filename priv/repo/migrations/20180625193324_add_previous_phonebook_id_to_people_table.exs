defmodule Texting.Repo.Migrations.AddPreviousPhonebookIdToPeopleTable do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :previous_phonebook_id, :int
    end
  end
end
