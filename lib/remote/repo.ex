defmodule Remote.Repo do
  use Ecto.Repo,
    otp_app: :remote,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 50, max_page_size: 50
end
