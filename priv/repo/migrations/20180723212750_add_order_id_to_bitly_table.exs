defmodule Texting.Repo.Migrations.AddOrderIdToBitlyTable do
  use Ecto.Migration

  def change do
    alter table(:bitly) do
      add :order_id, references(:orders)
    end
  end
end
