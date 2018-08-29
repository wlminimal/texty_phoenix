defmodule TextingWeb.Helpers.PublicHelpers do
  use Phoenix.HTML

  def error_message(form, field) do
    case form.errors[field] do
      {message, _} ->
        content_tag :p, class: "" do
          message
        end
      nil -> ""
    end
  end
end
