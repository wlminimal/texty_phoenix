defmodule TextingWeb.Dashboard.Admin.CampaignAdminController do
  use TextingWeb, :controller
  alias Texting.Sales
  alias Texting.AmazonS3.S3Helpers
  alias Texting.Messenger
  alias Timex
  alias Texting.Helpers
  alias Texting.Bitly
  alias Texting.{Account, Analytics}

  @doc """
  showing campaign history detail
  """
  @one_week 60 * 60 * 24 * 7
  def index(conn, %{"id" => id} = params) do

    order = Sales.get_order_by_order_id(id)
    user = Account.get_user_by_id(order.user_id)
    message_status = Messenger.get_all_message_status(order.id)
    deilvered_count = Analytics.get_delivered_message_status_count(message_status)
		undelivered_count = Analytics.get_undelivered_message_status_count(message_status)
		total_sent = Enum.count(message_status)
    # Get Bitly
    bitly = Bitly.get_bitly_by_order_id(order.id)
    has_bitly = if bitly !== nil do
                  true
                else
                  false
                end
    # Get message status with pagination
    message_status = Messenger.get_message_status_with_pagination(id, params)
    if order.message_type == "mms" do
      current_datetime = Timex.now
      url = case Helpers.compare_datetime(current_datetime, order.media_url_exp) do
              {:expired} ->
                config = S3Helpers.get_aws_s3_config()
                bucket = S3Helpers.get_bucket_name()
                {:ok, url} = S3Helpers.get_presigned_url(config, :get, bucket, order.s3_filename, @one_week)
                media_url_exp = Helpers.add_days_to_current_time(5)
                changeset = Sales.change_order(order, %{"media_url_exp" => media_url_exp, "media_url" => url})
                results = Sales.update_order(changeset)


                url
              {:not_expired} ->
                order.media_url
            end
      render conn, "index.html",
             campaign: order,
             image_url: url,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: true,
             deilvered_count: deilvered_count,
             undelivered_count: undelivered_count,
             total_sent: total_sent
    else
      render conn, "index.html",
             campaign: order,
             image_url: nil,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: false,
             deilvered_count: deilvered_count,
             undelivered_count: undelivered_count,
             total_sent: total_sent
    end
  end
end
