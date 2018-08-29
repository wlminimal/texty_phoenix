defmodule Texting.Repo.Migrations.AlterTwilioInsertedAtColumn do
  use Ecto.Migration

  def change do
    alter table("twilio") do
      modify :inserted_at, :datetime, default: fragment("NOW()")
    end
  end
end
