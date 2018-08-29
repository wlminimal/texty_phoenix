defmodule Texting.Repo.Migrations.ChangeDateFieldInInvoicesTable do
  use Ecto.Migration

  def change do
    alter table :invoices do
      modify :date, :timestamp
    end
  end
end
