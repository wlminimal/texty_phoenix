defmodule Texting.Repo.Migrations.AlterOrdersCountsField do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :counts, :integer
    end
  end
end


# ALTER TABLE orders ALTER COLUMN counts TYPE integer USING counts::integer;
