defmodule TextingWeb.Plugs.CaseStudyLayout do
  import Phoenix.Controller, only: [put_layout: 2]

  def init(_opts), do: nil

  def call(conn, _) do
    conn
    |> put_layout({TextingWeb.LayoutView, "app_case_study.html"})
  end
end
