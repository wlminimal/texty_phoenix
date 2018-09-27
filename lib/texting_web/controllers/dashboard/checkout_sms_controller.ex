defmodule TextingWeb.Dashboard.CheckoutSmsController do
  use TextingWeb, :controller
  alias Texting.{Sales, Bitly}

  def show_sms(conn, _params) do
    recipients = conn.assigns.recipients

    case recipients.counts == 0 do
      true ->
        conn
        |> put_flash(:info, "Your recipients list is empty. Add recipients first!")
        |> redirect(to: phonebook_path(conn, :index))

      false ->
        recipients_changeset = Sales.change_recipients(recipients)
        user = conn.assigns.current_user
        render conn, "send_sms.html",
                      recipients: recipients,
                      recipients_changeset: recipients_changeset,
                      user: user,
                      long_url: "",
                      shorten_url: "",
                      bitlink_id: ""
    end
  end

  @doc """
  get information and put_session and redirect to checkout preview page
  """
  def preview_sms(conn, %{"sms" => %{"message" => message,
                                     "total_credit" => credit_used,
                                     "name" => name,
                                     "description" => description,
                                     "bitlink_id" => bitly_id}}) do


    recipients = conn.assigns.recipients
    # get generated bitly by id
    bitly = Texting.Bitly.get_not_saved_bitly_by_order_id(recipients.id)

    attrs = %{
            "message" => message,
            "total" => credit_used,
            "name" => name,
            "description" => description,
            "bitly_id" => bitly.id
          }

    order = Sales.update_recipients(recipients, attrs)
    conn = assign(conn, :recipients, order)
    IO.puts "++++++++++BITLY+++++++++++++++++++++++"
    IO.inspect bitly
    IO.puts "++++++++++BITLY_ID+++++++++++++++++++++++"
    IO.inspect bitly_id
    IO.puts "++++++++++++++attrs+++++++++++++++++++"
    IO.inspect attrs
    conn
    |> redirect(to: checkout_sms_preview_path(conn, :index))

    # if date and time is not specified in front end,
    # redirect and show errors

    # recipients = conn.assigns.recipients
    # attrs = cond do
    #   time_to_send == "now" or time_to_send == "" ->
    #     %{
    #       "message" => message,
    #       "total" => credit_used,
    #       "name" => name,
    #       "description" => description,
    #       "scheduled" => false,
    #       "schedule_job_success" => false,
    #       "schedule_datetime" => Timex.now
    #     }
    #   time_to_send == "scheduled" ->
    #     if date == "" or time == "" do
    #       conn
    #       |> put_flash(:error, "Please check a date and time.")
    #       |> redirect(to: checkout_sms_path(conn, :show_sms))
    #     else
    #       # Build datetime in naive datetime format
    #       datetime = Formatter.build_datetime(date, time)
    #       IO.puts "++++++++++++++++++++ datetime +++++++++++++++++++++"
    #       IO.inspect datetime
    #       case Formatter.schedule_datetime_is_future?(datetime) do
    #         true ->

    #           %{
    #             "message" => message,
    #             "total" => credit_used,
    #             "name" => name,
    #             "description" => description,
    #             "scheduled" => true,
    #             "schedule_job_success" => false,
    #             "schedule_datetime" => datetime
    #           }
    #         false ->
    #           conn
    #           |> put_flash(:error, "Schedule time must be a future.")
    #           |> redirect(to: checkout_sms_path(conn, :show_sms))
    #       end
    #     end

    #   end
  end
end
