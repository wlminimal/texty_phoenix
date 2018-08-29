defmodule Texting.Repo.Migrations.AddAdminFieldToUser do
  use Ecto.Migration

  def change do
    alter table :users do
      add :admin, :boolean, default: false
    end
  end
end
