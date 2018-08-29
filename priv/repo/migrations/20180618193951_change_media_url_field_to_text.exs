defmodule Texting.Repo.Migrations.ChangeMediaUrlFieldToText do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :media_url, :text
    end
  end
end
