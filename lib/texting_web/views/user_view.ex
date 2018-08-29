defmodule TextingWeb.UserView do
  use TextingWeb, :view

  def first_name(user) do
    user.first_name
  end
end
