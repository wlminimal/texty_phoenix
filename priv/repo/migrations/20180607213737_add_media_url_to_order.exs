defmodule Texting.Repo.Migrations.AddMediaUrlToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :media_url, :string
    end
  end
end
