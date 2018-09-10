defmodule Texting.Repo.Migrations.AddEmailVerifiedFieldToUserTable do
  use Ecto.Migration

  def change do
    alter table :users do
      add :email_verified, :boolean, default: false
    end
  end
end
