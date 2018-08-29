defmodule Texting.Repo.Migrations.AlterTwilioUpdatedAtColumn do
  use Ecto.Migration

  def change do
    alter table("twilio") do
      modify :updated_at, :utc_datetime, default: fragment("NOW()")
    end
  end
end
