defmodule Texting.Repo.Migrations.AddPhonenumberToUser do
  use Ecto.Migration

  def change do
  	alter table(:users) do
  		add :phone_number, :integer
  	end
  end
end
