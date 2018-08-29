defmodule Texting.Repo.Migrations.AddPhoneVerifiedToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :phone_verified, :boolean
  	end
  end
end
