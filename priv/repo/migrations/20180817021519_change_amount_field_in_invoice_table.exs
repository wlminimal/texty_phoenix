defmodule Texting.Repo.Migrations.ChangeAmountFieldInInvoiceTable do
  use Ecto.Migration

  def change do
    alter table :invoices do
      modify :amount, :integer
    end
  end
end
