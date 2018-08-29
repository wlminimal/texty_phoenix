defmodule :"Elixir.Texting.Repo.Migrations.Add s3Filename field to orderTable" do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :s3_filename, :string
    end
  end
end
