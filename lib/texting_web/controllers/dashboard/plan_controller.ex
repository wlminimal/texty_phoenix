defmodule TextingWeb.Dashboard.PlanController do
  use TextingWeb, :controller
  alias Texting.Messenger
  alias Texting.Finance

  # @unit_price_tier_1 5 # 0.05
  # @unit_price_tier_2 4.5
  # @unit_price_tier_3 4
  # @unit_price_tier_4 3.5
  # @unit_price_tier_5 3
  # @unit_price_tier_6 2.5
  # @unit_price_tier_7 2


  def new(conn, _params) do
    user = conn.assigns.current_user
    free_plan_id = System.get_env("FREE_PLAN_ID")
    bronze_plan_id = System.get_env("BRONZE_PLAN_ID")
    silver_plan_id = System.get_env("SILVER_PLAN_ID")
    gold_plan_id = System.get_env("GOLD_PLAN_ID")
    platinum_plan_id = System.get_env("PLATINUM_PLAN_ID")
    diamond_plan_id = System.get_env("DIAMOND_PLAN_ID")
    master_plan_id = System.get_env("MASTER_PLAN_ID")
    grandmaster_plan_id = System.get_env("GRANDMASTER_PLAN_ID")
    render conn, "new.html",
                 user: user,
                 free_plan_id: free_plan_id,
                 bronze_plan_id: bronze_plan_id,
                 silver_plan_id: silver_plan_id,
                 gold_plan_id: gold_plan_id,
                 platinum_plan_id: platinum_plan_id,
                 diamond_plan_id: diamond_plan_id,
                 master_plan_id: master_plan_id,
                 grandmaster_plan_id: grandmaster_plan_id
  end

  @doc """
  Changing Plan
  """

  def create(conn, %{"plan_id" => plan_id}) do
    IO.puts "+++++++++++++++++++++++++++++++"
    IO.puts "This is plan_id+++++++++++++++++"
    IO.inspect plan_id
    IO.puts "+++++++++++++++++++++++++++++++"

    user = conn.assigns.current_user
    # Get plan name, amount, id
    %{ nickname: plan_name } = Finance.get_plan_by_id(plan_id)
    subscription_id = Finance.get_subscription_id(user)
    stripe_changeset = Finance.change_stripe(user.stripe)
    twilio_changeset = Messenger.change_twilio(user.twilio)
    free_plan_id = System.get_env("FREE_PLAN_ID")

    if plan_id == free_plan_id do
      # By default user can't post request with free plan..but user can downgrade to free plan
      # release all phone number
      downgrade_to_free_plan(user)

      conn
      |> put_flash(:info, "Downgraded to Free plan")
      |> redirect(to: plan_path(conn, :new))
    else
      with {:free_plan, true} <- Finance.user_is_free_plan?(user) do
        # User upgrade Free plan to Paid Plan so create twilio account..
        # create twilio sub account and twilio messaging service with phone number

        case Finance.change_plan(subscription_id, plan_id) do
          {:ok, _plan} ->
            # add stripe info
            Ecto.Changeset.change(stripe_changeset, %{plan_name: plan_name, plan_id: plan_id})
            |> Finance.update_stripe()

            # create twilio subaccount and messaging service
            twilio_changeset_done = twilio_changeset
              |> Messenger.create_twilio_subaccount(user)
              |> Messenger.create_twilio_messaging_service(user)
              |> Messenger.set_available_phonenumber_counts(plan_name)
            case Messenger.update_twilio(twilio_changeset_done) do
              {:ok, twilio} ->

                # buy phone number and create phonenumber table in database.

                Messenger.adjust_phonenumbers(user, twilio)
                conn
                |> put_flash(:info, "Your plan is updated successfully!.Check business phone numbers!")
                |> redirect(to: account_info_path(conn, :index))
              {:error, _reason} ->
                conn
                |> put_flash(:error, "Something wrong. Please contact us")
                |> redirect(to: sign_in_path(conn, :new))
            end

          # We need user's card information
          # So redirecto to payment page and return to plan page
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> put_session(:redirect_from_plan_page, true)
            |> redirect(to: payment_path(conn, :new))
        end
      else
        # user is paid plan, don't need to create a twilio account
        {:paid_plan, false} ->
          case Finance.change_plan(subscription_id, plan_id) do
            {:ok, _plan} ->
               # add stripe info
              Ecto.Changeset.change(stripe_changeset, %{plan_name: plan_name, plan_id: plan_id})
              |> Finance.update_stripe()

              # update available phone number in twilio
              twilio_changeset = twilio_changeset
                |> Messenger.set_available_phonenumber_counts(plan_name)
              case Messenger.update_twilio(twilio_changeset) do
                {:ok, twilio} ->
                  Messenger.adjust_phonenumbers(user, twilio)
                  conn
                  |> put_flash(:info, "Your plan is updated successfully!")
                  |> redirect(to: plan_path(conn, :new))
                {:error, _reason} ->
                  conn
                  |> put_flash(:error, "Something wrong. Please contact us")
                  |> redirect(to: plan_path(conn, :new))
              end

            {:error, message} ->
              conn
              |> put_flash(:info, message)
              |> put_session(:redirect_from_plan_page, true)
              |> redirect(to: payment_path(conn, :new))
          end
      end
    end


  end


  def downgrade_to_free_plan(user) do
    stripe_changeset = Finance.change_stripe(user.stripe)
    free_plan_id = System.get_env("FREE_PLAN_ID")
    # cancel subscription at_period_end
    subs_id = user.stripe.subscription_id
    Finance.cancel_subscription(subs_id)

    # and remove and release phone number
    account_sid = user.twilio.account
    token = user.twilio.token

    user.phonenumbers
    |> Enum.map(& &1.phonenumber_sid)
    |> Enum.map(& Messenger.release_phone_number(&1, account_sid, token))

     # Delete phone numbers from database
     Messenger.delete_all_phonenumbers(user)

     # delete twilio sub-account
     Messenger.close_twilio_account(account_sid)

     # Set free account info to Twilio Struct
    twilio = Messenger.get_twilio_by_user_id(user.id)
    twilio_changeset = Messenger.change_twilio(twilio)
    {twilio_sid, twilio_token, twilio_msid} = Messenger.set_free_account_info_to_user()
    twilio_changeset = Ecto.Changeset.change(twilio_changeset, %{account: twilio_sid, token: twilio_token, msid: twilio_msid, available_phone_number_count: 0})
    Messenger.update_twilio(twilio_changeset)

    # Update stipre's plan info
    stripe_changeset = Ecto.Changeset.change(stripe_changeset, %{plan_name: "Free", plan_id: free_plan_id})
    Finance.update_stripe(stripe_changeset)
  end
end
