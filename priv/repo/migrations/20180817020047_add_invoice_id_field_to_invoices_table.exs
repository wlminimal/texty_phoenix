defmodule Texting.Repo.Migrations.AddInvoiceIdFieldToInvoicesTable do
  use Ecto.Migration

  def change do
    alter table :invoices do
      add :invoice_id, :string
    end
  end
end
