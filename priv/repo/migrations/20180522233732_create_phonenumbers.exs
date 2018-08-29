defmodule Texting.Repo.Migrations.CreatePhonenumbers do
  use Ecto.Migration

  def change do
    create table(:phonenumbers) do
      add :number, :string
      add :account_sid, :string
      add :phonenumber_sid, :string
      add :friendly_name, :string
      add :user_id, references(:users)
      timestamps()
    end

  end
end
