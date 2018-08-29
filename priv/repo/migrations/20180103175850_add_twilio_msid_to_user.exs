defmodule Texting.Repo.Migrations.AddTwilioMsidToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :twilio_msid, :string
  	end
  end
end
