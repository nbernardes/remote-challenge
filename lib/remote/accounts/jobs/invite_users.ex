defmodule Remote.Accounts.Jobs.InviteUsers do
  @moduledoc """
  The primary role of this worker is to send invitation emails to all users who
  have an active salary. In case an email fails to be sent, the worker will
  automatically retry sending it until it successfully goes through.

  Please note that we do not employ any sophisticated retry strategies. Instead,
  we rely on a simple approach of repeating the process for failed emails on a
  page until all emails on that page are successfully sent. It's worth
  mentioning that the library responsible for sending emails has a failure rate
  of 1 in 500,000 emails sent, so let's keep our fingers crossed and hope for
  the best! 😂
  """
  use Oban.Worker, queue: :invites

  alias Remote.Accounts
  alias Remote.Repo

  # Since this is an internal worker, we can bump up the amount of data we
  # collect from the database on each page.
  @page_size 1000

  @impl Oban.Worker
  def perform(%Oban.Job{} = job) do
    invite_users_per_page(job)
  end

  # To avoid asking to the database all users at once, we'll get them paginated,
  # send invite emails to that page, retry for the ones that fail and once the
  # page is completed, go to the next one until we reach the last page.
  defp invite_users_per_page(job, page \\ 1) do
    users_page =
      Accounts.get_active_salary_users_page(
        pagination: [page: page, page_size: @page_size]
      )

    :ok = invite_users(users_page.entries)
    {:ok, updated_job} = update_worker_info(job, users_page)

    if page >= users_page.total_pages do
      :ok
    else
      invite_users_per_page(updated_job, page + 1)
    end
  end

  defp invite_users([]), do: :ok

  defp invite_users(users) do
    failed_users =
      Enum.reduce_while(users, [], fn user, acc ->
        acc =
          case BEChallengex.send_email(user) do
            {:ok, _} -> acc
            _ -> [user | acc]
          end

        {:cont, acc}
      end)

    invite_users(failed_users)
  end

  defp update_worker_info(job, users_page) do
    additional_info = %{
      page_number: users_page.page_number,
      total_entries: users_page.total_entries,
      total_pages: users_page.total_pages
    }

    args = Map.put(job.args, :additional_info, additional_info)

    job
    |> Ecto.Changeset.change(%{args: args})
    |> Repo.update()
    |> case do
      {:ok, updated_job} -> {:ok, updated_job}
      _ -> {:ok, job}
    end
  end
end
