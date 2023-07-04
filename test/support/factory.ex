defmodule Remote.Factory do
  @moduledoc """
  Factories to be used for database data creation when testing
  """
  use ExMachina.Ecto, repo: Remote.Repo

  alias Remote.Accounts.Salary
  alias Remote.Accounts.User
  alias Remote.Utils.Currency

  def user_factory do
    %User{name: Faker.Person.name()}
  end

  def salary_factory do
    %Salary{
      amount:
        Money.new(
          :rand.uniform(100),
          Enum.random(Currency.supported_currencies())
        ),
      user: build(:user)
    }
  end
end
