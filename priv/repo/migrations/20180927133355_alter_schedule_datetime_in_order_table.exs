defmodule Texting.Repo.Migrations.AlterScheduleDatetimeInOrderTable do
  use Ecto.Migration

  def change do
    alter table :orders do
      modify :schedule_datetime, :timestamp, default: fragment("NOW()")
    end
  end
end
