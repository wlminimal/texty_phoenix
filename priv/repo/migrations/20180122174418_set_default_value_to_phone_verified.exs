defmodule Texting.Repo.Migrations.SetDefaultValueToPhoneVerified do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		modify :phone_verified, :boolean, default: false
  	end
  end
end
