defmodule Texting.Repo.Migrations.AddScheduleFieldToOrderTable do
  use Ecto.Migration

  def change do
    alter table :orders do
      add :scheduled, :boolean, default: false
      add :schedule_job_success, :boolean, default: false
      add :schedule_datetime, :timestamp
    end
  end
end
