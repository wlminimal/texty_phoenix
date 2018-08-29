defmodule TextingWeb.Dashboard.AnalyticsCommander do
  use Drab.Commander
  alias Texting.{Sales, Messenger, Analytics, Bitly}

  defhandler show_stats(socket, sender) do
    order_id = sender.params["campaign_id"]
    user_id = socket.assigns.current_user_id
    order = Sales.get_order_by_id(order_id, user_id)
    message_status = Messenger.get_all_message_status(order_id)

    total_sent = Enum.count(message_status)
    IO.inspect total_sent
    deilvered_count = Analytics.get_delivered_message_status_count(message_status)
    IO.inspect deilvered_count
    undelivered_count = Analytics.get_undelivered_message_status_count(message_status)

    IO.inspect undelivered_count
    bitly = Bitly.get_bitly_by_order_id(order_id)
    total_clicks = Analytics.load_clicks(bitly)

    poke socket,
                total_sent: total_sent,
                deilvered_count: deilvered_count,
                undelivered_count: undelivered_count,
                total_clicks: total_clicks
                # recent_campaign: order

    socket |> exec_js!("AnalyticsChart.update()")
  end
end
