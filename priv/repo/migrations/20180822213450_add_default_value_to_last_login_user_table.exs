defmodule Texting.Repo.Migrations.AddDefaultValueToLastLoginUserTable do
  use Ecto.Migration

  def change do
    alter table :users do
      modify :last_login, :timestamp, default: fragment("NOW()")
    end
  end
end
