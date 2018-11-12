defmodule TextingWeb.Dashboard.AnalyticsCommander do
  use Drab.Commander
  alias Texting.{Sales, Messenger, Analytics, Bitly}

  defhandler show_stats(socket, sender) do
    order_id = sender.params["campaign_id"]
    user_id = socket.assigns.current_user_id
    order = Sales.get_order_by_id(order_id, user_id)
    message_status = Messenger.get_all_message_status(order_id)

    total_sent = Enum.count(message_status)
    IO.inspect(total_sent)
    deilvered_count = Analytics.get_delivered_message_status_count(message_status)
    IO.inspect(deilvered_count)
    undelivered_count = Analytics.get_undelivered_message_status_count(message_status)

    IO.inspect(undelivered_count)
    bitly = Bitly.get_bitly_by_order_id(order_id)
    total_clicks = Analytics.load_clicks(bitly)

    # recent_campaign: order
    IO.puts("++++ setting_props ++++")
    t0 = :os.system_time(:milli_seconds)

    set_prop!(socket, "#total-sent", %{"attributes" => %{"data-total-sent" => total_sent}})
    set_prop!(socket, "#total-sent", innerHTML: total_sent)

    set_prop!(socket, "#deilvered-count", %{
      "attributes" => %{"data-deilvered-count" => deilvered_count}
    })

    set_prop!(socket, "#deilvered-count", innerHTML: deilvered_count)

    set_prop!(socket, "#undelivered-count", %{
      "attributes" => %{"data-undelivered-count" => undelivered_count}
    })

    set_prop!(socket, "#undelivered-count", innerHTML: undelivered_count)

    set_prop!(socket, "#total-clicks", %{"attributes" => %{"data-total-clicks" => total_clicks}})
    set_prop!(socket, "#total-clicks", innerHTML: total_clicks)

    IO.puts("+++++++++++++ setting_props is done ++++++++++")
    IO.puts("it took #{:os.system_time(:milli_seconds) - t0} ms")

    # recent_order: order
    IO.puts("++++ update charts ++++")
    socket |> exec_js!("AnalyticsChart.update()")
  end
end
