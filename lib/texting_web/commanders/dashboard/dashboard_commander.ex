defmodule TextingWeb.Dashboard.DashboardCommander do
  use Drab.Commander
  alias Texting.{Sales, Messenger, Analytics, Bitly}

  defhandler show_dashboard_stats(socket, sender) do
    order_id = sender.params["campaign_id"]
    IO.puts("++++ Order id ++++")
    IO.inspect(order_id)

    user_id = socket.assigns.current_user_id
    IO.puts("++++ get_order_by_id ++++")
    order = Sales.get_order_by_id(order_id, user_id)

    IO.puts("++++ get_all_message_status ++++")
    message_status = Messenger.get_all_message_status(order_id)

    IO.puts("++++ Enum.count(message_status) ++++")
    total_sent = Enum.count(message_status)

    IO.puts("++++ get_delivered_message_status_count ++++")
    deilvered_count = Analytics.get_delivered_message_status_count(message_status)

    IO.puts("++++ get_undelivered_message_status_count ++++")
    undelivered_count = Analytics.get_undelivered_message_status_count(message_status)

    IO.puts("++++ get_bitly_by_order_id ++++")
    bitly = Bitly.get_bitly_by_order_id(order_id)

    IO.puts("++++ load_clicks ++++")
    total_clicks = Analytics.load_clicks(bitly)

    # {total_sent, deilvered_count, undelivered_count, total_clicks} =
    #   Analytics.get_total_analytics(user_id, order_id)

    IO.puts("++++ poking ++++")

    poke(socket,
      total_sent: total_sent,
      deilvered_count: deilvered_count,
      undelivered_count: undelivered_count,
      total_clicks: total_clicks
    )

    # recent_order: order
    IO.puts("++++ update charts ++++")
    socket |> exec_js!("DashboardChart.update()")
  end
end
