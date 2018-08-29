defmodule TextingWeb.Dashboard.AnalyticsController do
  use TextingWeb, :controller
  alias Texting.{Analytics, Sales, Messenger, Bitly, Contact}

  def index(conn, params) do
    user = conn.assigns.current_user
    orders = Sales.get_all_confirmed_status_order_with_pagination(user.id, params)
    all_contacts = Contact.get_all_people_count(user.id)
    unsubscriber_phonebook = Contact.get_or_create_unsubscribed_contact(user)

    unsubscriber_count = Enum.count(Contact.get_people(unsubscriber_phonebook.id))
    if Enum.empty?(orders) do
      render conn, "index.html",
                    campaigns: [],
                    total_sent: 0,
                    deilvered_count: 0,
                    undelivered_count: 0,
                    total_clicks: 0,
                    recent_campaign: nil,
                    has_campaign: false,
                    all_contacts: all_contacts,
                    unsubscriber_count: unsubscriber_count
    else
      [recent_order] = Enum.take(orders, 1)
      message_status = Messenger.get_all_message_status(recent_order.id)
      total_sent = Enum.count(message_status)
      deilvered_count = Analytics.get_delivered_message_status_count(message_status)
      undelivered_count = Analytics.get_undelivered_message_status_count(message_status)
      bitly = Bitly.get_bitly_by_order_id(recent_order.id)
      # Check if order has bitly link
      total_clicks = Analytics.load_clicks(bitly)
      render conn, "index.html",
                    campaigns: orders,
                    total_sent: total_sent,
                    deilvered_count: deilvered_count,
                    undelivered_count: undelivered_count,
                    total_clicks: total_clicks,
                    recent_campaign: recent_order,
                    has_campaign: true,
                    all_contacts: all_contacts,
                    unsubscriber_count: unsubscriber_count
    end


  end
end
