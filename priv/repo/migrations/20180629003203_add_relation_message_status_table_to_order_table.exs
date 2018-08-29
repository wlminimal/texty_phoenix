defmodule Texting.Repo.Migrations.AddRelationMessageStatusTableToOrderTable do
  use Ecto.Migration

  def change do
    alter table(:message_status) do
      add :order_id, references(:orders, on_delete: :nothing)
    end
  end
end
