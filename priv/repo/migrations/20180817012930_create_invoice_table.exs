defmodule Texting.Repo.Migrations.CreateInvoiceTable do
  use Ecto.Migration

  def change do
    create table :invoices do
      add :amount, :string
      add :description, :string
      add :type, :string
      add :date, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
