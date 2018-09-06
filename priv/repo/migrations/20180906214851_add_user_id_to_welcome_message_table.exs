defmodule Texting.Repo.Migrations.AddUserIdToWelcomeMessageTable do
  use Ecto.Migration

  def change do
    alter table :welcome_message do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
