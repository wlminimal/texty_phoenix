defmodule TextingWeb.Dashboard.CheckoutMmsCommander do
  use Drab.Commander

  alias Texting.{Analytics, Bitly}

  # Using Task.Supervisor.async_stream for Bitly API Request
  defhandler shorten_url(socket, sender) do
    long_url = sender.params["long_url_textarea"]
    #user_id = Drab.Core.get_session(socket, :user_id)
    user_id = socket.assigns.current_user_id
    order_id = socket.assigns.order_id
    long_url = String.trim(long_url)
    case Analytics.create_short_link(long_url) do
      {:ok, results} ->
        # Create bitly struct
        %{id: bitlink_id, link: bitlink_url, long_url: _long_url} = results
        {:ok, bitly} = Bitly.create_bitly(%{bitlink_id: bitlink_id, bitlink_url: bitlink_url, long_url: long_url, total_clicks: 0, user_id: user_id, order_id: order_id})

        poke socket, shorten_url: bitlink_url, long_url: long_url, bitlink_id: bitly.id
      {:error, errors} ->
        IO.puts "++++++++++++++++++++++++++++++++++++++"
        IO.inspect errors
        IO.puts "++++++++++++++++++++++++++++++++++++++"
        set_prop socket, "#long-url-error", innerHTML: "Something wrong found in your url. Make sure including http://, for example http://www.example.com"
    end
  end
end
