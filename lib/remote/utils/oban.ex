defmodule Remote.Utils.Oban do
  @moduledoc """
  Utility functions to work with Oban
  """
  import Remote.Utils.Result
  import Ecto.Query

  alias Remote.Repo

  @typep job :: Oban.Job.t()

  @doc """
  This function will get the worker by the ID generated on our side via a
  snowflake
  """
  @spec get_worker(integer) :: {:ok, job} | {:error, :not_found}
  def get_worker(id) do
    Oban.Job
    |> where([o], fragment("args->>'id' = ?", ^id))
    |> Repo.one()
    |> normalize()
  end
end
