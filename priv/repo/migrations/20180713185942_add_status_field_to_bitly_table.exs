defmodule Texting.Repo.Migrations.AddStatusFieldToBitlyTable do
  use Ecto.Migration

  def change do
    alter table(:bitly) do
      add :status, :string
    end
  end
end
