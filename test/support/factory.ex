defmodule Remote.Factory do
  @moduledoc """
  Factories to be used for database data creation when testing
  """
  use ExMachina.Ecto, repo: Remote.Repo

  alias Remote.Accounts.User

  def user_factory do
    %User{name: Faker.Person.name()}
  end
end
