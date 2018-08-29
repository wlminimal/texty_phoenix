defmodule Texting.Repo.Migrations.AddNameFieldToMessageStatus do
  use Ecto.Migration

  def change do
    alter table(:message_status) do
      add :name, :string
    end
  end
end
