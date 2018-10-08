defmodule TextingWeb.Dashboard.CampaignHistoryController do
  use TextingWeb, :controller

  alias Texting.AmazonS3.S3Helpers
  alias Texting.{Messenger, Helpers, Bitly, Sales}
  alias Texting.Contact.SearchContact
  alias Timex

  def index(conn, params) do
    user = conn.assigns.current_user
    campaigns_history = Sales.get_all_confirmed_status_order_with_pagination(user.id, params)
    render conn, "index.html", campaigns_history: campaigns_history
  end

  @one_week 60 * 60 * 24 * 7
  # Search by name
  def show(conn, %{"id" => id, "name" => _name} = params) do
    user = conn.assigns.current_user
    order = Sales.get_order_by_id(id, user.id)
    # Get Bitly
    bitly = Bitly.get_bitly_by_order_id(order.id)
    has_bitly = if bitly !== nil do
                  true
                else
                  false
                end
    # Get message status with pagination
    # message_status = Messenger.get_message_status_with_pagination(id, params)
    message_status = SearchContact.get_search_results_in_camp_history(conn, params, order.id)
    # Check order media url exp date
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

                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"
                IO.inspect results
                IO.inspect changeset
                IO.inspect media_url_exp
                IO.inspect url
                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"

                url
              {:not_expired} ->
                url = order.media_url
            end
      render conn, "search_results.html",
             campaign: order,
             image_url: url,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: true
    else
      render conn, "search_results.html",
             campaign: order,
             image_url: nil,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: false
    end

  end

  @doc """
  Search by recipients number
  """
  def show(conn, %{"id" => id, "to" => _to} = params) do
    user = conn.assigns.current_user
    order = Sales.get_order_by_id(id, user.id)
    # Get Bitly
    bitly = Bitly.get_bitly_by_order_id(order.id)
    has_bitly = if bitly !== nil do
                  true
                else
                  false
                end
    # Get message status with pagination
    message_status = SearchContact.get_search_results_in_camp_history(conn, params, order.id)

    # Check order media url exp date
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

                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"
                IO.inspect results
                IO.inspect changeset
                IO.inspect media_url_exp
                IO.inspect url
                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"

                url
              {:not_expired} ->
                url = order.media_url
            end
      render conn, "search_results.html",
             campaign: order,
             image_url: url,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: true
    else
      render conn, "search_results.html",
             campaign: order,
             image_url: nil,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: false
    end
  end

  @doc """
  Filter by status
  """
  def show(conn, %{"id" => id, "by_status" => _to} = params) do
    user = conn.assigns.current_user
    order = Sales.get_order_by_id(id, user.id)
    # Get Bitly
    bitly = Bitly.get_bitly_by_order_id(order.id)
    has_bitly = if bitly !== nil do
                  true
                else
                  false
                end
    # Get message status with pagination
    message_status = SearchContact.get_search_results_in_camp_history(conn, params, order.id)

    # Check order media url exp date
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

                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"
                IO.inspect results
                IO.inspect changeset
                IO.inspect media_url_exp
                IO.inspect url
                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"

                url
              {:not_expired} ->
                url = order.media_url
            end
      render conn, "search_results.html",
             campaign: order,
             image_url: url,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: true
    else
      render conn, "search_results.html",
             campaign: order,
             image_url: nil,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: false
    end
  end

  @doc """
  Default show function in campaign history
  """

  def show(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user
    order = Sales.get_order_by_id(id, user.id)
    # Get Bitly
    bitly = Bitly.get_bitly_by_order_id(order.id)
    has_bitly = if bitly !== nil do
                  true
                else
                  false
                end
    # Get message status with pagination
    message_status = Messenger.get_message_status_with_pagination(id, params)

    # Check order media url exp date
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

                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"
                IO.inspect results
                IO.inspect changeset
                IO.inspect media_url_exp
                IO.inspect url
                IO.puts "+++++++++++++++++++++++++++++++++++++++++++++++"

                url
              {:not_expired} ->
                url = order.media_url
            end
      render conn, "show.html",
             campaign: order,
             image_url: url,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: true
    else
      render conn, "show.html",
             campaign: order,
             image_url: nil,
             message_statuses: message_status,
             bitly: bitly,
             has_bitly: has_bitly,
             has_image: false
    end

  end
end
