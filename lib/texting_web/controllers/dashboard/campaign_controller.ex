defmodule TextingWeb.Dashboard.CampaignController do
  use TextingWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
