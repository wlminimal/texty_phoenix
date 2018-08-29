defmodule Texting.Repo.Migrations.AlterStripeTimestampsTime do
  use Ecto.Migration

  def change do
    alter table("stripe") do
      modify :inserted_at, :utc_datetime, default: fragment("NOW()")
      modify :updated_at, :utc_datetime, default: fragment("NOW()")
    end
  end
end
