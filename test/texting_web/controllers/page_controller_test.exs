defmodule TextingWeb.PageControllerTest do
  use TextingWeb.ConnCase
  alias TextingWeb.Fixture

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ " 고객들과 소통하는"
  end

  test "user_fixture return correct user" do
    user = Fixture.user_fixture(%{})
    assert user.email == "some@example.com"
  end
end
