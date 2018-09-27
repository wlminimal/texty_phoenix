defmodule Texting.Repo.Migrations.AddBitlyIdFieldToOrderTable do
  use Ecto.Migration

  def change do
    alter table :orders do
      add :bitly_id, :integer
    end
  end
end
