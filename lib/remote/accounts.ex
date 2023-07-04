defmodule Remote.Accounts do
  @moduledoc "The accounts context."
  import Ecto.Query

  alias Remote.Accounts.User
  alias Remote.Repo

  @typep changeset(x) :: Ecto.Changeset.t(x)
  @typep create_user_attrs :: %{name: binary}
  @typep user :: User.t()
  @typep page :: Scrivener.Page.t()

  @spec create_user(create_user_attrs) ::
          {:ok, user} | {:error, changeset(user)}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec list_users_paginated(keyword) :: page
  def list_users_paginated(opts \\ []) do
    pagination = opts[:pagination] || []
    search = parse_search(opts[:search])
    order = parse_order(search, opts[:order])

    User
    |> filter_search(search)
    |> order_search(search, order)
    |> Repo.paginate(pagination)
  end

  defp parse_search(nil), do: "%%"

  defp parse_search(search) do
    "%#{String.trim(search)}%"
  end

  # When there is a search and no order, we want to show on the top by default
  # the users that have a bigger similar match. If no search is given, we want
  # to show the users alphabetically ordered.
  defp parse_order("%%", nil), do: :asc
  defp parse_order(_, nil), do: :desc

  defp parse_order(_, order) do
    String.trim(order)
    |> String.downcase()
    |> case do
      "asc" -> :asc
      _ -> :desc
    end
  end

  defp filter_search(query, "%%"), do: query

  defp filter_search(query, search) do
    where(query, [u], ilike(u.name, ^search))
  end

  defp order_search(query, "%%", order) do
    order_by(query, [u], {^order, u.name})
  end

  defp order_search(query, search, order) do
    order_by(
      query,
      [u],
      {^order, fragment("similarity(?, ?)", ^search, u.name)}
    )
  end
end
