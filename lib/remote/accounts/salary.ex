defmodule Remote.Accounts.Salary do
  @moduledoc "The Salary schema"
  use Remote.Ecto.Schema

  import Ecto.Changeset

  alias Remote.Accounts.User

  schema "salaries" do
    field :amount, Money.Ecto.Map.Type
    field :inactive_since, :utc_datetime_usec

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(salary, attrs) do
    salary
    |> cast(attrs, ~w(amount user_id inactive_since)a)
    |> validate_required(~w(amount user_id)a)
    |> validate_unique_active_per_user()
  end

  defp validate_unique_active_per_user(changeset) do
    case get_field(changeset, :inactive_since) do
      nil ->
        unique_constraint(changeset, :user_id,
          name: :salaries_unique_active_per_user,
          message: "only one active salary allowed per user"
        )

      _ ->
        changeset
    end
  end
end
