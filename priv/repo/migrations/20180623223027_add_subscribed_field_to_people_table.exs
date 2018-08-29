defmodule Texting.Repo.Migrations.AddSubscribedFieldToPeopleTable do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :subscribed, :boolean, default: true
    end
  end
end
