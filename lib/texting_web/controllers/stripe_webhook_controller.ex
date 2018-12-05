defmodule TextingWeb.StripeWebhookController do
  use TextingWeb, :controller

  alias Texting.{Messenger, Finance, Account}

  @doc """
  Handle Stripe invoiceitem.created webhook.
  This occurs when user subscribe to plan or upgrade or downgrade.
  So adjust credits accordingly.
  """
  def handle_invoiceitem_created(conn, params) do
    # IO.inspect params
    %{
      "data" => %{
        "object" => %{
          "amount" => amount,
          "customer" => stripe_id,
          "plan" => %{"nickname" => plan_name, "id" => _plan_id}
        }
      }
    } = params

    IO.inspect(params)
    # Get customer id and query it from database.
    # user = Account.get_user_by_stripe_id(stripe_id)
    # user_changeset = Account.change_user(user)
    # Calculate credits to add.
    # user_changeset
    # |> Credit.add_extra_amount(amount, plan_name)
    # |> Account.update_user

    send_resp(conn, 200, "")
  end

  @doc """
  User cancel subscription.
  1. Delete phone numbers from database
  2. Release Phone number in twilio
  3. Delete twilio account

  #Not using this webhook right now.
  """
  def handle_subscription_deleted(conn, params) do
    %{"data" => %{"object" => %{"id" => sub_id}}} = params
    IO.inspect(sub_id)
    # Get user id
    %{user_id: user_id} = Finance.get_stripe_by_subs_id(sub_id)
    user = Account.get_user_by_id(user_id)
    # account_sid = user.twilio.account # get account sid
    # token = user.twilio.token # get account token
    # TODO: change to live version before deploy
    # Testing
    # twilio.account
    account_sid = System.get_env("TWILIO_TEST_ACCOUNT_SID")
    # twilio.token
    token = System.get_env("TWILIO_TEST_AUTH_TOKEN")

    user.phonenumbers
    |> Enum.map(& &1.phonenumber_sid)
    |> Enum.map(&Messenger.release_phone_number(&1, account_sid, token))

    # Delete phone numbers from database
    Messenger.delete_all_phonenumbers(user)

    # delete twilio sub-account
    Messenger.close_twilio_account(account_sid)

    # Set free account info to Twilio Struct
    twilio = Messenger.get_twilio_by_user_id(user_id)
    twilio_changeset = Messenger.change_twilio(twilio)
    {twilio_sid, twilio_token, twilio_msid} = Messenger.set_free_account_info_to_user()

    twilio_changeset =
      Ecto.Changeset.change(twilio_changeset, %{
        account: twilio_sid,
        token: twilio_token,
        msid: twilio_msid,
        available_phone_number_count: 0
      })

    Messenger.update_twilio(twilio_changeset)

    send_resp(conn, 200, "")
  end

  @doc """
  Handle invoice payment succeeded event in Stripe.
  Get information from stripe event and create invoice struct and
  save to the database.
  """
  def handle_invoice_payment_succeeded(conn, params) do
    IO.puts("++++++++++++Invoice Payment Succeeded++++++++++++++")
    IO.inspect(params)
    IO.puts("++++++++++++Invoice Payment Succeeded++++++++++++++")

    %{
      "data" => %{
        "object" => %{
          "customer" => stripe_id,
          "number" => receipt_number,
          "lines" => %{
            "data" => [
              %{
                "amount" => amount,
                "description" => description,
                "id" => invoice_id,
                "type" => type,
                "period" => %{"end" => _end, "start" => date}
              }
            ]
          }
        }
      }
    } = params

    IO.puts("++++++++++++receipt_number++++++++++++++")
    IO.inspect(receipt_number)
    IO.inspect(stripe_id)
    IO.inspect(amount)
    IO.inspect(description)
    IO.inspect(invoice_id)
    IO.inspect(type)
    IO.inspect(date)

    Finance.create_invoice(params)
    send_resp(conn, 200, "")
  end

  @doc """
  Handle charge.succeeded event in Stripe
  This happens when buy credit happens and succeeds
  Get Information from stripe event and create charge struct and
  save to the database.
  TODO: Instead using webhook, I chose to implement while user make a payment...
  """
  def handle_charge_succeeded(conn, params) do
    IO.puts("+++++++++++ Charge Succeeded +++++++++++++")
    IO.inspect(params)
    IO.puts("+++++++++++++++++++++++++++++++++++++++++++++++++++")

    send_resp(conn, 200, "")
  end
end
