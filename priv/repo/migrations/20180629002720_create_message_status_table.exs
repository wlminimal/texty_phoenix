defmodule Texting.Repo.Migrations.CreateMessageStatusTable do
  use Ecto.Migration

  def change do
    create table(:message_status) do
      add :to, :string
      add :from, :string
      add :message, :string
      add :status, :string
      add :message_sid, :string
      add :account_sid, :string

      timestamps()
    end
  end
end
