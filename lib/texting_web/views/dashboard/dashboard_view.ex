defmodule TextingWeb.Dashboard.DashboardView do
	use TextingWeb, :view
	alias Texting.{Formatter, Analytics}

	def display_datetime(datetime) do
    Formatter.display_date_time(datetime)
	end

	def calculate_percentage(campaign_id) do
		Analytics.calculate_delivery_rate(campaign_id)
	end
end
