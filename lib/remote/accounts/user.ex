defmodule Remote.Accounts.User do
  @moduledoc "The User schema"
  use Remote.Ecto.Schema

  import Ecto.Changeset

  alias Remote.Accounts.Salary

  schema "users" do
    field :name, :string
    field :latest_salary, :map, virtual: true

    has_one :active_salary, Salary, where: [inactive_since: nil]
    has_many :salaries, Salary

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w(name)a)
    |> validate_required(~w(name)a)
  end
end
