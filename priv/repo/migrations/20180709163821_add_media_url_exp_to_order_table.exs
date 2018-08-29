defmodule Texting.Repo.Migrations.AddMediaUrlExpToOrderTable do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :media_url_exp, :timestamp
    end
  end
end
