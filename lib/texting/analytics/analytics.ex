defmodule Texting.Analytics do
  alias Bitly.Bitly, as: BitlyApp
  alias Texting.{Bitly, Messenger, Formatter, Sales}

  # To check function performance
  use Appsignal.Instrumentation.Decorators

  def create_short_link(long_url) do
    domain = System.get_env("BITLY_DOMAIN")
    group_guid = System.get_env("BITLY_GROUP_ID")

    case BitlyApp.shorten(long_url, domain, group_guid) do
      {:ok, results} -> {:ok, results}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_click_summary(bitlink_id) do
    case BitlyApp.click_summary(bitlink_id) do
      {:ok, %{total_clicks: total_clicks}} -> total_clicks
      {:error, errors} -> {:errors, errors}
    end
  end

  @decorate transaction_event()
  def get_undelivered_message_status_count(message_status) do
    message_status
    |> Enum.filter(fn ms -> ms.status !== "delivered" end)
    |> Enum.count()
  end

  @decorate transaction_event()
  def get_delivered_message_status_count(message_status) do
    message_status
    |> Enum.filter(fn ms -> ms.status == "delivered" end)
    |> Enum.count()
  end

  @doc """
  Get Click summary and update Bitly
  """
  def load_clicks(bitly) when bitly == nil, do: 0

  @decorate transaction_event()
  def load_clicks(%Bitly{} = bitly) do
    total_clicks = get_click_summary(bitly.bitlink_id)
    Bitly.update(bitly, %{total_clicks: total_clicks})
    total_clicks
  end

  def calculate_delivery_rate(order_id) do
    message_status = Messenger.get_all_message_status(order_id)
    total_count = Enum.count(message_status)
    delivery_count = get_delivered_message_status_count(message_status)

    percentage_number = delivery_count / total_count * 100
    Formatter.display_percentage(percentage_number)
  end

  @doc """
  For displaying time in Dashboard page

  Campaign sent 8 days ago
  """
  def get_time_last_sent_message(user_id, message_type) do
    most_recent_campaign = Sales.get_most_recent_order_by_type(user_id, message_type)

    cond do
      Enum.count(most_recent_campaign) <= 0 ->
        "You have 0 history."

      Enum.count(most_recent_campaign) > 0 ->
        [most_recent_campaign] = most_recent_campaign
        Timex.from_now(most_recent_campaign.inserted_at)
    end
  end

  @doc """
  For display update time in Dashboard page for Analytics

  updated 2 mins ago.
  """
  def get_time_last_updated_message_status(user_id) do
    [most_recent_campaign] = Sales.get_most_recent_order(user_id)
    [message_status] = Messenger.get_most_recent_updated_message_status(most_recent_campaign.id)
    Timex.from_now(message_status.updated_at)
  end

  @doc """

  """
  # def get_total_analytics(user_id, order_id) do
  #   order = Sales.get_order_by_id(order_id, user_id)
  #   message_status = Messenger.get_all_message_status(order_id)

  #   total_sent = Enum.count(message_status)
  #   deilvered_count = get_delivered_message_status_count(message_status)
  #   undelivered_count = get_undelivered_message_status_count(message_status)
  #   bitly = Bitly.get_bitly_by_order_id(order_id)
  #   total_clicks = load_clicks(bitly)

  #   {total_sent, deilvered_count, undelivered_count, total_clicks}
  # end
end
