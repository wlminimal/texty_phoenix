defmodule Texting.SalesTest do
  use Texting.DataCase
  alias Texting.Fixture

  test "create_initial_order" do
    user = Fixture.user_fixture(%{})
    order = Fixture.order_fixture(user)
    assert order.status == "Recipients List"
  end
end
