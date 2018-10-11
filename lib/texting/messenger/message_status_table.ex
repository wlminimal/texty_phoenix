defmodule Texting.MessageStatusTable do
  use GenServer
  alias Texting.{Messenger, Formatter}

  def start_link(_opts) do
    IO.puts "Starting message status table server..."
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, table}
  end

  @doc """
  key : messageSid
  value: list of smsStatus and from number.
  """
  def put(key, status, from_number) do
    cond do
      status in ["delivered", "undelivered"] ->
        :ets.insert(__MODULE__, {key, [status, from_number]})
        # get message_status by messageSid(Key)
        message_status = Messenger.get_message_status_by_message_sid(key)
        IO.puts "++++++++++++++++++ message status struct +++++++++++++++++++++++"
        IO.inspect message_status
        # Save to database..
        from_number = Formatter.remove_plus_sign_from_phonenumber(from_number)
        Messenger.update_message_status(message_status, %{from: from_number, status: status} )
        IO.puts "Saved to database!"

        # Delete data maybe?

      true ->
        :ets.insert(__MODULE__, {key, [status, from_number]})
    end

  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end
end
