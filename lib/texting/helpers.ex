defmodule Texting.Helpers do
  alias Timex

  # def add_days_to_current_time(days) do
  #   Timex.add(Timex.now, Timex.Duration.from_days(days)) |> Ecto.DateTime.cast!
  # end

  # def compare_datetime(current_datetime, saved_datetime) do
  #   current_datetime = current_datetime |> Ecto.DateTime.cast!
  #   saved_datetime = saved_datetime |> Ecto.DateTime.cast!
  #   case Ecto.DateTime.compare(current_datetime, saved_datetime) do
  #     :gt ->
  #       # current datetime is future
  #       {:expired}
  #     :lt ->
  #       # saved datetime is future
  #       {:not_expired}
  #     _   ->
  #       {:expired}
  #   end
  # end

  def add_days_to_current_time(days) do
    Timex.add(Timex.now, Timex.Duration.from_days(days))
  end

  def compare_datetime(current_datetime, saved_datetime) do
    case Timex.compare(current_datetime, saved_datetime) do
      1  ->
        # current datetime is future
        {:expired}
      -1 ->
        # saved datetime is future
        {:not_expired}
      _   ->
        {:expired}
    end
  end
end
