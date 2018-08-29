defmodule TextingWeb.Dashboard.DashboardController do
	use TextingWeb, :controller
	alias Texting.{Sales, Messenger, Analytics, Bitly}
	def new(conn, _) do
		user = conn.assigns.current_user
		campaigns = Sales.get_all_confirmed_status_order(user.id, 5)

		cond do
			Enum.count(campaigns) <= 0 ->
				render(conn, "index.html",
											has_campaign: false,
											campaigns: [],
											total_sent: 0,
											deilvered_count: 0,
											undelivered_count: 0,
											total_clicks: 0,
											recent_order: nil,
											sms_time: "No history at all",
											mms_time: "No history at all",
											analytics_time: "No history at all")
			Enum.count(campaigns) > 0 ->
				[recent_order] = Enum.take(campaigns, 1)
				message_status = Messenger.get_all_message_status(recent_order.id)
				total_sent = Enum.count(message_status)
				deilvered_count = Analytics.get_delivered_message_status_count(message_status)
				undelivered_count = Analytics.get_undelivered_message_status_count(message_status)
				bitly = Bitly.get_bitly_by_order_id(recent_order.id)
				# Check if order has bitly link
				total_clicks = Analytics.load_clicks(bitly)

				# Get most recent campaign time
				sms_time = Analytics.get_time_last_sent_message(user.id, "sms")
				mms_time = Analytics.get_time_last_sent_message(user.id, "mms")
				analytics_time = Analytics.get_time_last_updated_message_status(user.id)
				render(conn, "index.html",
											has_campaign: true,
											campaigns: campaigns,
											total_sent: total_sent,
											deilvered_count: deilvered_count,
											undelivered_count: undelivered_count,
											total_clicks: total_clicks,
											recent_order: recent_order,
											sms_time: sms_time,
											mms_time: mms_time,
											analytics_time: analytics_time)
		end
	end
end
