defmodule Rumbl.Repo.Migrations.CreateCategoreis do
  use Ecto.Migration

  def change do
    create table(:categoreis) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:categoreis, [:name])
  end
end
