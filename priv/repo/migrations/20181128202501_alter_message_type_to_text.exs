defmodule Texting.Repo.Migrations.AlterMessageTypeToText do
  use Ecto.Migration

  def change do
    alter table(:message_status) do
      modify(:message, :text)
    end
  end
end
