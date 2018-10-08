defmodule Texting.PaginationHelpers do
  @moduledoc false

  def to_list(input, namespace) do
    input |> Enum.map(fn {key, value} -> parse("#{namespace}[#{key}]", value) end)
  end

  def to_list(input) do
    input |> Enum.map(fn {key, value} -> parse(key, value) end)
  end

  def parse(key, value) when is_map(value), do: to_list(value, key)

  def parse(key, value), do: ["#{key}": value]
end
