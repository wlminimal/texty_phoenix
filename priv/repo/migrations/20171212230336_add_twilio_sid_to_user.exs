defmodule Texting.Repo.Migrations.AddTwilioSidToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :twilio_sid, :string
  	end
  end
end
