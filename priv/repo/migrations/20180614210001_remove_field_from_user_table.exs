defmodule Texting.Repo.Migrations.RemoveFieldFromUserTable do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :provider
      remove :stripe_id
      remove :twilio_sid
      remove :twilio_token
      remove :twilio_msid
      remove :plan
      remove :plan_id
    end
  end
end
