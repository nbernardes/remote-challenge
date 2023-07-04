defmodule Remote.Accounts do
  @moduledoc "The accounts context."
  import Ecto.Query

  alias Remote.Accounts.Salary
  alias Remote.Accounts.User
  alias Remote.Repo

  @typep changeset(x) :: Ecto.Changeset.t(x)
  @typep create_salary_attrs :: %{
           amount: Money.t(),
           user_id: User.id(),
           inactive_at: DateTime.t()
         }
  @typep create_user_attrs :: %{name: binary}
  @typep page :: Scrivener.Page.t()
  @typep salary :: Salary.t()
  @typep user :: User.t()

  #
  # User
  #

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
    |> join_user_salaries()
    |> filter_search(search)
    |> order_search(search, order)
    |> Repo.paginate(pagination)
  end

  # Join the active salary, if the user has one
  # Join the latest inactive salary, if the user has one
  # TODO: Solve the problem when two salaries have the same inactive_at, we get
  # duplicated results because when joining the `inactive_salary` it finds two
  # salaries for a given user with the same `inactive_at`.
  defp join_user_salaries(query) do
    max_inactive_at_subquery =
      Salary
      |> where([s], not is_nil(s.inactive_at))
      |> group_by([s], s.user_id)
      |> select([s], %{user_id: s.user_id, max_inactive_at: max(s.inactive_at)})

    query
    |> join(:left, [u], as in assoc(u, :active_salary), as: :as)
    |> join(:left, [u], mia in subquery(max_inactive_at_subquery),
      on: mia.user_id == u.id,
      as: :mia
    )
    |> join(:left, [u, mia: mia], is in Salary,
      on: is.user_id == u.id and is.inactive_at == mia.max_inactive_at,
      as: :is
    )
    |> select([u, as: as, is: is], %{
      u
      | active_salary: as,
        latest_inactive_salary: is
    })
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

  #
  # Salary
  #

  @spec create_salary(create_salary_attrs) ::
          {:ok, salary} | {:error, changeset(salary)}
  def create_salary(attrs) do
    %Salary{}
    |> Salary.changeset(attrs)
    |> Repo.insert()
  end
end
