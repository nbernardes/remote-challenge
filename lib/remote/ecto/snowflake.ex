defmodule Remote.Ecto.Snowflake do
  @moduledoc """
  To avoid ID Enumeration attacks, all tables defined with schemas on the app
  will be using Snowflake IDs. Even though elixir supports binary IDs as a more
  fast and easy approach, snowflake IDs have certain advantages over binary IDs.

  1. Distributed Generation: Snowflake IDs are designed to be generated in a
  distributed manner, meaning that multiple systems/servers can generate unique
  IDs without conflicts.

  2. Scalability: Snowflake IDs can be generated at a high rate without
  sacrificing uniqueness.

  3. Sorting and Ordering: Snowflake IDs are generated in a way that ensures
  they are roughly sortable by the time they were generated.

  4. Reduced Collisions: Snowflake IDs use a combination of timestamp, machine
  identifier and sequence number to generate the IDs.

  5. Compact Representation: Snowflake IDs are typically represented as 64-bit
  integers, which makes them more compact than binary IDs in many cases.
  """
  use Ecto.Type

  def type, do: :integer

  def cast(value), do: convert(value)

  def load(value), do: convert(value)

  def dump(value), do: convert(value)

  def autogenerate do
    # We want it to crash if snowflake can't generate an ID
    {:ok, id} = Snowflake.next_id()

    id
  end

  defp convert(value) when is_integer(value), do: {:ok, value}

  defp convert(value) when is_binary(value) do
    {:ok, String.to_integer(value)}
  rescue
    _e in ArgumentError ->
      {:error, value}
  end
end
