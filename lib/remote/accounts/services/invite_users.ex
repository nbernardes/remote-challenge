defmodule Remote.Accounts.Services.InviteUsers do
  @moduledoc false

  alias Remote.Accounts.Jobs
  alias Remote.Ecto

  @typep oban_job :: Oban.Job.t()
  @typep oban_changeset :: Oban.Job.changeset()

  @spec call :: {:ok, oban_job} | {:error, oban_changeset}
  def call do
    Jobs.InviteUsers.new(%{id: Ecto.Snowflake.autogenerate()})
    |> Oban.insert()
  end
end
