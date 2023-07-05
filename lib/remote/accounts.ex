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
           inactive_since: DateTime.t()
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
    |> join_user_latest_salary()
    |> filter_search(search)
    |> order_search(search, order)
    |> Repo.paginate(pagination)
  end

  # Joins the latest salary of each user. The latest salary is determined by
  # being the active salary (where `inactive_since` is nil) or the most recent
  # inactive salary (the one with the highest `inactive_since` timestamp).
  defp join_user_latest_salary(query) do
    query
    |> join(:left, [u], s in subquery(user_latest_salary_query()),
      on: s.user_id == u.id,
      as: :s
    )
    |> select([u, s: s], %{u | latest_salary: s})
  end

  # Selects the salary with the lowest `row_num` from the query
  # `inactive_since_ordered_salaries_query`, ensuring that we choose the active
  # salary or the most recent inactive salary.
  defp user_latest_salary_query do
    Salary
    |> join(
      :inner,
      [s],
      ios in subquery(inactive_since_ordered_salaries_query()),
      on: ios.id == s.id,
      as: :ios
    )
    |> where([s, ios: ios], ios.row_num == 1)
  end

  # Retrieves all the salaries, ordering them by inactive_since (with nulls
  # appearing first), and assigns a row_num per user_id to handle cases where
  # multiple salaries have the same `inactive_since`.
  defp inactive_since_ordered_salaries_query do
    Salary
    |> select([s], %{
      user_id: s.user_id,
      inactive_since: s.inactive_since,
      id: s.id,
      row_num:
        fragment(
          "ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY inactive_since DESC)"
        )
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
      [
        {^order, fragment("similarity(?, ?)", ^search, u.name)},
        {:asc, u.name}
      ]
    )
  end

  @spec get_active_salary_users_page(keyword) :: page
  def get_active_salary_users_page(opts \\ []) do
    pagination = opts[:pagination] || []

    User
    |> join(:inner, [u], s in assoc(u, :active_salary))
    |> select([u], %{name: u.name})
    |> Repo.paginate(pagination)
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
