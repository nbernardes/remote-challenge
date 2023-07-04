defmodule Remote.Ecto.Schema do
  @moduledoc """
  Module to be used on all the schemas defined on the app. Using this module
  ensures that all tables are defined with Snowflake IDs and timestamps are
  always `utc_datetime_usec`
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      use Ecto.Schema

      @primary_key {:id, Remote.Ecto.Snowflake, autogenerate: true}
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
