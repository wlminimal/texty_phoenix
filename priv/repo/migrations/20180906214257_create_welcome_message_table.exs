defmodule Texting.Repo.Migrations.CreateWelcomeMessageTable do
  use Ecto.Migration

  def change do
    create table(:welcome_message) do
      add :message, :text
    end
  end
end
