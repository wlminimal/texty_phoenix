defmodule Texting.Messenger do

  import Ecto.Query
  import Ecto
  alias Messageman
  alias Texting.Messenger.{Twilio, Phonenumber, MessageStatus}
  alias Texting.Repo
  alias Texting.Formatter
  alias Texting.Contact

  ###################################################################
  # MessageStatus Struct
  ###################################################################

  @doc """
  params = list from Send sms or Send Mms result.
  """

  def create_message_status(list, order_id, user_id) do
    list
    |> extracting_msessage(order_id, user_id)
    |> Enum.map(&MessageStatus.changeset(&1, %{}))
    |> Enum.map(&Repo.insert/1)
  end

  def extracting_msessage(results, order_id, user_id) do
    for %{account_sid: account_sid, body: body, message_sid: message_sid, status: status, to: to} <- results do
      to = Formatter.remove_plus_sign_from_phonenumber(to)
      people = Contact.get_people_by_phonenumber(user_id, to)
      person = List.first(people)
      if person.name == nil do
        name = "N/A"
        %MessageStatus{to: to, from: nil, message: body,
        status: status, message_sid: message_sid,
        account_sid: account_sid, order_id: order_id, name: name}
      else
        name = person.name
        %MessageStatus{to: to, from: nil, message: body,
        status: status, message_sid: message_sid,
        account_sid: account_sid, order_id: order_id, name: name}
      end

    end
  end

  def get_message_status_with_pagination(order_id, params) do
    query = from m in MessageStatus, where: m.order_id == ^order_id
    Repo.paginate(query, params)
  end

  def get_message_status_by_message_sid(message_sid) do
    query = from m in MessageStatus, where: m.message_sid == ^message_sid
    Repo.one(query)
  end

  def update_message_status(%MessageStatus{} = message_status, attrs \\ %{}) do
    message_status
    |> MessageStatus.changeset(attrs)
    |> Repo.update()
  end

  def get_message_status_by_status(order_id, status) do
    query = from m in MessageStatus, where: m.order_id == ^order_id and m.status == ^status
    Repo.all(query)
  end

  def get_all_message_status(order_id) do
    query = from m in MessageStatus, where: m.order_id == ^order_id
    Repo.all(query)
  end

  def get_most_recent_updated_message_status(order_id) do
    query = from m in MessageStatus, where: m.order_id == ^order_id, order_by: [desc: m.updated_at], limit: 1
    Repo.all(query)
  end




  ###################################################################
  # Twilio Struct
  ###################################################################
  def create_twilio(user, attrs \\ %{}) do
    build_assoc(user, :twilio)
    |> Twilio.changeset(attrs)
   # |> Repo.insert() # Repo.insert() calling in codeverify_controller..
  end

  def insert_twilio(changeset) do
    changeset
    |> Repo.insert
  end

  def update_twilio(changeset) do
    changeset
    |> Repo.update
  end

  def change_twilio(%Twilio{} = twilio) do
    twilio
    |> Twilio.changeset(%{})
  end

  def change_twilio(%Twilio{} = twilio, attrs \\ %{}) do
    twilio
    |> Twilio.changeset(attrs)
  end

  def get_twilio_by_user_id(user_id) do
    query = from t in Twilio, where: t.user_id == ^user_id
    Repo.one(query)
  end

  def get_twilio_struct(account_sid) do
    query = from t in Twilio, where: t.account == ^account_sid
    Repo.one(query)
  end

  def set_free_account_info_to_user() do
    # return master account's twilio_msid, account, token for free plan user
    twilio_sid = System.get_env("TWILIO_FREE_ACCOUNT_SID")
    twilio_token = System.get_env("TWILIO_FREE_AUTH_TOKEN")
    twilio_msid = System.get_env("TWILIO_FREE_MESSAGING_SID")

    {twilio_sid, twilio_token, twilio_msid}
  end


  ###################################################################
  # Twilio Account
  ###################################################################

  def create_twilio_subaccount(changeset, user) do
    email = user.email
    { sid, token, _friendly_name } = Messageman.create_account(email)
    Ecto.Changeset.change(changeset, %{account: sid, token: token})
  end

  def get_twilio_account(account_sid) do
    Messageman.get_account(account_sid)
  end

  def suspend_twilio_account(account) do
    Messageman.suspend_account(account)
  end

  def close_twilio_account(account_sid) do
    Messageman.close_account(account_sid)
  end

  def reactivate_twilio_account(account) do
    Messageman.reactivate_account(account)
  end

  def set_available_phonenumber_counts(changeset, plan_name) do
    plan_name = String.upcase(plan_name)
    available_phonenumber_counts = System.get_env(plan_name <> "_PLAN_PHONENUMBER_COUNTS")
    {counts, ""} = Integer.parse(available_phonenumber_counts)
    IO.puts "++++++++++++++PHONENUMBER COUNTS+++++++++++++++++"
    IO.inspect counts
    IO.puts "+++++++++++++++++++++++++++++++++++++"
    Ecto.Changeset.change(changeset, %{available_phone_number_count: counts})
  end

  ###################################################################
  # Messaging Service
  ###################################################################

  def create_twilio_messaging_service(changeset, user) do
    email = user.email
    twilio_sid = changeset.changes.account
    token = changeset.changes.token
    incoming_request_url = System.get_env("TWILIO_INCOMING_REQUEST_URL")
    twilio_msid = Messageman.create_messaging_service(twilio_sid, token, email, incoming_request_url)
    Ecto.Changeset.change(changeset, %{msid: twilio_msid})
  end

  def add_phone_number_to_messaging_service(phone_sid, msid, account, token) do
    Messageman.add_phone_number_to_messaging_service(phone_sid, msid, account, token)
  end

  ###################################################################
  # Incoming Phone Numbers
  ###################################################################

  def create_phonenumber(user, attrs \\ %{}) do
    build_assoc(user, :phonenumbers)
    |> Phonenumber.changeset(attrs)
    |> Repo.insert!
  end

  def get_phonenumbers(user) do
    query = from p in Phonenumber, where: p.user_id == ^user.id
    Repo.all(query)
  end

  def get_phonenumbers(user, count) do
    query = from p in Phonenumber, where: p.user_id == ^user.id, limit: ^count
    Repo.all(query)
  end

  # def delete_phonenumbers(phone_sid) do
  #   query = from p in Phonenumber, where: p.phonenumber_sid == ^phone_sid
  #   Repo.delete!(query)
  # end

  def delete_phonenumbers(phonenumber) do
    phonenumber
    |> Repo.delete!
  end

  def delete_all_phonenumbers(user) do
    query = from p in Phonenumber, where: p.user_id == ^user.id
    Repo.delete_all(query)
  end

  def buy_phone_number(area_code, account, token) do
    Messageman.IncomingPhoneNumber.buy_phone_number(area_code, account, token)
  end

  def release_phone_number(phone_sid, account, token) do
    Messageman.IncomingPhoneNumber.release_phone_number(phone_sid, account, token)
  end

  @doc """
  1. Buy phone number
  2. Add phone number info to database
  3. Add phone number to messaging service
  """
  def buy_and_setup_phonenumber(user, twilio, count) do
    area_code = Texting.Formatter.get_user_area_code(user)

    account = twilio.account #System.get_env("TWILIO_TEST_ACCOUNT_SID")
    token = twilio.token #System.get_env("TWILIO_TEST_AUTH_TOKEN")
    msid = twilio.msid
    Enum.each(1..count, fn _n ->
      phonenumber = buy_phone_number(area_code, account, token)
      create_phonenumber(user, %{number: phonenumber.phone_number,
                                 account_sid: phonenumber.account_sid,
                                 phonenumber_sid: phonenumber.sid,
                                 friendly_name: phonenumber.friendly_name})

      add_phone_number_to_messaging_service(phonenumber.sid, msid, account, token)
    end)
  end

  # this is for dev only
  # def buy_and_setup_phonenumber(user, twilio, count) do
  #   #TODO: Use customer's area code in production
  #   area_code = Texting.Formatter.get_user_area_code(user)

  #   account = System.get_env("TWILIO_TEST_ACCOUNT_SID")
  #   token = System.get_env("TWILIO_TEST_AUTH_TOKEN")
  #   msid = twilio.msid
  #   Enum.each(1..count, fn _n ->
  #     phonenumber = buy_phone_number(500, account, token)
  #     create_phonenumber(user, %{number: phonenumber.phone_number,
  #                                account_sid: phonenumber.account_sid,
  #                                phonenumber_sid: phonenumber.sid,
  #                                friendly_name: phonenumber.friendly_name})

  #     add_phone_number_to_messaging_service(phonenumber.sid, msid, account, token)
  #   end)
  # end

  def remove_and_release_phonenumber(user, twilio, count) do
    #TODO: Change to user's twilio account info
    account = twilio.account #System.get_env("TWILIO_TEST_ACCOUNT_SID")
    token = twilio.token #System.get_env("TWILIO_TEST_AUTH_TOKEN")
    phonenumbers = get_phonenumbers(user, count)
    Enum.each(phonenumbers, fn p ->
      release_phone_number(p.phonenumber_sid, account, token)
      delete_phonenumbers(p)
    end)
  end

  def adjust_phonenumbers(user, twilio) do
    # Check if user is upgrading or downgrading by phonenumbers..
    current_phonenumbers = Enum.count(user.phonenumbers)
    available_phonenumbers = twilio.available_phone_number_count

    cond do
      current_phonenumbers > available_phonenumbers ->
        # user is downgrading plan
        count = current_phonenumbers - available_phonenumbers
        # remove it
        remove_and_release_phonenumber(user, twilio, count)

      current_phonenumbers < available_phonenumbers ->
        # user is upgrading plan
        count = available_phonenumbers - current_phonenumbers
        # buy it
        buy_and_setup_phonenumber(user, twilio, count)
    end
  end

end
