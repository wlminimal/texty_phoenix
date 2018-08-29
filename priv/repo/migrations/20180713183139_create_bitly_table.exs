defmodule Texting.Repo.Migrations.CreateBitlyTable do
  use Ecto.Migration

  def change do
    create table(:bitly) do
      add :bitlink_id, :string
      add :bitlink_url, :string
      add :long_url, :string
      add :total_clicks, :integer, default: 0

      add :user_id, references(:users)
      timestamps()
    end
  end
end
