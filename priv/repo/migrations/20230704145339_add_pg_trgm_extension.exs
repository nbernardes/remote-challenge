defmodule Remote.Repo.Migrations.AddPgTrgmExtension do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
  end
end
