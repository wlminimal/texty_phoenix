defmodule Texting.Repo.Migrations.RemovePhoneNumbersFromTwilioTable do
  use Ecto.Migration

  def change do
    alter table("twilio") do
      remove :phone_numbers
    end
  end
end
