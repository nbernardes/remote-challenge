defmodule Remote.Accounts.User do
  @moduledoc "The User schema"
  use Remote.Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w(name)a)
    |> validate_required(~w(name)a)
  end
end
