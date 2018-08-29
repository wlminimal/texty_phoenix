defmodule Texting.Repo.Migrations.AddTwilioTable do
  use Ecto.Migration

  def change do
    create table("twilio") do
      add :account, :string
      add :token, :string
      add :msid, :string
      add :phone_numbers, {:array, :string}
      add :available_phone_number_count, :integer
      add :user_id, references(:users)

      timestamps()
    end
  end
end
