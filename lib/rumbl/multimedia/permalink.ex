defmodule Rumbl.Multimedia.Permalink do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  # Called when external data is passed into Ecto. 
  # It’s invoked when values in queries are interpolated or also by the cast function in changesets.
  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  # Invoked when data is sent to the database.
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  # Invoked when data is loaded from the database.
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
