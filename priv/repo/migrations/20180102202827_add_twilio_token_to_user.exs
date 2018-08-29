defmodule Texting.Repo.Migrations.AddTwilioTokenToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :twilio_token, :string
  	end
  end
end
