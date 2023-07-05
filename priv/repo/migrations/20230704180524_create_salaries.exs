defmodule Remote.Repo.Migrations.CreateSalaries do
  use Ecto.Migration

  def change do
    create table(:salaries) do
      add :amount, :map, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :inactive_since, :utc_datetime_usec

      timestamps()
    end

    # Create an index to optimize queries that will involve inactive salaries or
    # querying for the user active salary.
    create index(
             :salaries,
             [:user_id, :inactive_since],
             name: :salaries_user_id_inactive_since_index
           )

    # Create an unique index that ensures only one active salary exists per user
    create unique_index(:salaries, [:user_id],
             where: "(inactive_since IS NULL)",
             name: :salaries_unique_active_per_user
           )
  end
end
