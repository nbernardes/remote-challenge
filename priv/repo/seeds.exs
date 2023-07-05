# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Remote.Repo.insert!(%Remote.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Remote.Accounts
alias Remote.Utils.Currency

# Generate dates randomly in the previous 30 days. This actually solves the
# majority of the cases the TODO I left on the accounts/join_user_salaries
# function explains.
to = DateTime.utc_now()
from = DateTime.add(to, -30, :day)

Enum.each(1..20_000, fn _ ->
  {:ok, user} = Accounts.create_user(%{name: Faker.Person.name()})

  # As per challenge requirement, it is asked that, for each user, we generate
  # two salaries. The salaries can both be inactive, or only one active.
  # Use 4+ currencies
  salary_1 = :rand.uniform(100_000)
  salary_2 = :rand.uniform(100_000)
  currency = Enum.random(Currency.supported_currencies())

  # The first salary will be the one that will vary from active/inactive. To make
  # this variation, we check if the generated salary remainder from 2 is zero.
  # This leads so some randomness on the results, which is what we want. For the
  # second salary, it will always be inactive.
  inactive_at =
    if rem(salary_1, 2) == 0, do: nil, else: Faker.DateTime.between(from, to)

  Enum.each(
    [{salary_1, inactive_at}, {salary_2, Faker.DateTime.between(from, to)}],
    fn {amount, inactive_at} ->
      {:ok, _} =
        Accounts.create_salary(%{
          amount: Money.new(amount, currency),
          user_id: user.id,
          inactive_at: inactive_at
        })
    end
  )
end)
