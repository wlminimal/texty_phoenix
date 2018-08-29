defmodule Texting.Repo.Migrations.AddReceiptNumberToInvoiceTable do
  use Ecto.Migration

  def change do
    alter table :invoices do
      add :receipt_number, :string, default: 0
    end
  end
end
