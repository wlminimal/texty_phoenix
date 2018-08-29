defmodule Texting.Account do
  import Ecto.Query
  alias Texting.Repo
  alias Texting.Account.User
  alias Texting.Messenger
  alias Timex


  def get_or_insert_user(changeset) do
    case get_user_by_email(changeset.changes.email) do
      nil ->
        insert_user(changeset)
      user ->
        {:ok, user}
    end
  end

  def insert_user(changeset) do
    changeset
    |> Repo.insert()
  end

  def update_user(changeset) do
    changeset
    |> Repo.update!()
  end

  def get_user_from_assigns(conn) do
    conn.assigns.current_user
  end
  def get_user_by_id(id) do
    Repo.one(from u in User, where: u.id == ^id, preload: [:twilio, :stripe, :orders, :phonebooks, :phonenumbers])
  end

  def get_user_by_email(email) do
    Repo.one(from u in User, where: u.email == ^email, preload: [:twilio, :stripe, :orders, :phonebooks, :phonenumbers])
  end

  def get_user_by_twilio(account_sid) do
    twilio = Messenger.get_twilio_struct(account_sid)
    query = from u in User, where: u.id == ^twilio.user_id, preload: [:phonebooks]
    Repo.one(query)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_from_number(user_id) do
    %{from_phone_numbers: from_numbers} = get_user_by_id(user_id)
    from_numbers
  end

  # passwordless login... generate_toke!
  def generate_token(user) do
    Phoenix.Token.sign(TextingWeb.Endpoint, "user", user.id)
  end

  @max_age 600 # 10 min
  def verify_token(token) do
    Phoenix.Token.verify(TextingWeb.Endpoint, "user", token, max_age: @max_age)
  end

  def timestamp_login_time(user) do
    now = Timex.now
    user_changeset =  change_user(user, %{last_login: now})
    IO.puts "+++++++user_changeset++++++++++++"
    IO.inspect user_changeset
    IO.puts "+++++++user_changeset++++++++++++"
    update_user(user_changeset)
  end
end
