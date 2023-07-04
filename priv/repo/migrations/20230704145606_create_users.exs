defmodule Remote.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :name, :string, null: false

      timestamps()
    end

    execute """
    CREATE INDEX users_name_gin_trgm_idx
    ON users
    USING gin (name gin_trgm_ops);
    """
  end

  def down do
    drop table(:users)
  end
end
