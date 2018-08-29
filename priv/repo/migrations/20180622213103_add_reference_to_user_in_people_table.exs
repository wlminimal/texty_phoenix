defmodule Texting.Repo.Migrations.AddReferenceToUserInPeopleTable do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :user_id, references(:users)
    end
  end
end
