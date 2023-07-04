defmodule RemoteWeb.AccountsController do
  use RemoteWeb, :controller

  alias Remote.Accounts

  def index(conn, params) do
    opts = [
      pagination: [page: params["page"], page_size: params["page_size"]],
      search: params["search"],
      order: params["order"]
    ]

    paginated_users = Accounts.list_users_paginated(opts)

    render(conn, :index, paginated_users: paginated_users)
  end
end
