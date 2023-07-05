defmodule RemoteWeb.AccountsController do
  use RemoteWeb, :controller

  alias Remote.Accounts
  alias Remote.Accounts.Services
  alias Remote.Utils

  action_fallback RemoteWeb.FallbackController

  def index(conn, params) do
    opts = [
      pagination: [page: params["page"], page_size: params["page_size"]],
      search: params["search"],
      order: params["order"]
    ]

    paginated_users = Accounts.list_users_paginated(opts)

    render(conn, :index, paginated_users: paginated_users)
  end

  def invite_users(conn, _) do
    with {:ok, job} <- Services.InviteUsers.call() do
      render(conn, :invite_users, job: job)
    end
  end

  def invite_users_status(conn, %{"id" => worker_id}) do
    with {:ok, job} <- Utils.Oban.get_worker(worker_id) do
      render(conn, :invite_users_status, job: job)
    end
  end
end
