defmodule Texting.Repo.Migrations.AddLastLoginFieldToUserTable do
  use Ecto.Migration

  def change do
    alter table :users do
      add :last_login, :timestamp
    end
  end
end
