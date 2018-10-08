defmodule TextingWeb.Fixture do
  alias Texting.{Account, Sales}
  alias Texting.Account.User


  def user_fixture(attrs \\ %{}) do
    attrs = attrs
      |> Enum.into(%{
        email: "some@example.com",
        first_name: "John",
        last_name: "Kim"
      })
    {:ok, user} = Account.change_user(%User{}, attrs) |> Account.get_or_insert_user()
    user
  end

  def order_fixture(user) do
    order = Sales.create_initial_order(user)
    order
  end
end
