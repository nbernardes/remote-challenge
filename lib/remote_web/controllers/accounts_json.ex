defmodule RemoteWeb.AccountsJSON do
  alias Remote.Accounts.Salary
  alias Remote.Accounts.User

  def index(%{paginated_users: %{entries: users} = paginated_users}) do
    %{
      data: for(user <- users, do: data(user)),
      page_number: paginated_users.page_number,
      page_size: paginated_users.page_size,
      total_pages: paginated_users.total_pages,
      total_entries: paginated_users.total_entries
    }
  end

  def invite_users(%{job: job}) do
    %{
      id: job.args.id,
      status: job.state
    }
  end

  def invite_users_status(%{job: job}) do
    %{
      id: job.args["id"],
      status: job.state,
      additional_info: %{
        page_number: job.args["additional_info"]["page_number"],
        total_entries: job.args["additional_info"]["total_entries"],
        total_pages: job.args["additional_info"]["total_pages"]
      }
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      salary: data(user.latest_salary),
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp data(%Salary{} = salary) do
    %{
      id: salary.id,
      amount: data(salary.amount),
      inactive_since: salary.inactive_since,
      inserted_at: salary.inserted_at,
      updated_at: salary.updated_at
    }
  end

  defp data(%Money{} = money) do
    %{
      value: money.amount,
      currency: money.currency,
      formatted: Money.to_string(money)
    }
  end

  defp data(_), do: nil
end
