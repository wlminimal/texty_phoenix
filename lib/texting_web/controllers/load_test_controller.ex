defmodule TextingWeb.LoadTestController do
  use TextingWeb, :controller

  def index(conn, _params) do
    render conn, "loaderio-f95477852e582a177f74a077dabf6ae9.html"
  end
end
