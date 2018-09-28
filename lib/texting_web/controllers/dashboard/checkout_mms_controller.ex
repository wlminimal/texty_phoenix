defmodule TextingWeb.Dashboard.CheckoutMmsController do
  use TextingWeb, :controller
  alias Texting.Sales
  alias Texting.AmazonS3.S3Helpers
  alias Texting.FileHandler

  use Drab.Controller, commanders: [TextingWeb.Dashboard.CheckoutSmsCommander]

  @spec show_mms(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def show_mms(conn, _params) do
    recipients = conn.assigns.recipients
    case recipients.counts == 0 do
      true ->
        conn
        |> put_flash(:info, "Your recipients list is empty. Add recipients first!")
        |> redirect(to: phonebook_path(conn, :index))

      false ->
        recipients_changeset = Sales.change_recipients(recipients)
        user = conn.assigns.current_user
        render conn, "send_mms.html",
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
  def preview_mms(conn, %{"mms" => %{"message" => message,
                                     "total_credit" => credit_used,
                                     "name" => name,
                                     "description" => description},
                                     "upload-image" => file}) do
    user = conn.assigns.current_user
    IO.puts "+++++++++++ upload file ++++++++++++++"
    IO.inspect file

    case FileHandler.validate_image_file?(file) do

      true ->
        case FileHandler.validate_size?(file) do
          true ->
            s3_filename = file
            |> FileHandler.get_extension()
            |> S3Helpers.create_s3_file_name(user)
            bucket_name = S3Helpers.get_bucket_name()
            {:ok, file_binary} = File.read(file.path)

            case S3Helpers.upload_file_to_S3(bucket_name, s3_filename, file_binary) do
              {:ok, url} ->
                # Save information to Order.
                recipients = conn.assigns.recipients
                bitly = Texting.Bitly.get_not_saved_bitly_by_order_id(recipients.id)
                bitly_id = if bitly == nil do
                             nil
                           else
                             bitly.id
                           end
                attrs = %{
                          "message" => message,
                          "total" => credit_used,
                          "media_url" => url,
                          "name" => name,
                          "description" => description,
                          "bitly" => bitly_id,
                          "s3_filename" => s3_filename
                        }
                order = Sales.update_recipients(recipients, attrs)
                conn = assign(conn, :recipients, order)
                conn
                |> put_flash(:info, "Upload successful. Your campaign is ready to send!")
                |> redirect(to: checkout_mms_preview_path(conn, :index))
              {:error, _message} ->
                conn
                |> put_flash(:error, "Erorr uploading!")
                |> redirect(to: checkout_mms_path(conn, :show_mms))
            end
          false ->
            conn
            |> put_flash(:error, "Your image is too big(max size is 2 MB).")
            |> redirect(to: checkout_mms_path(conn, :show_mms))
        end
      false ->
        conn
				|> put_flash(:error, "Please upload only .png, .jpg, jpeg")
				|> redirect(to: checkout_mms_path(conn, :show_mms))
    end
  end
end
