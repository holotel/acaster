defmodule Acaster.Repo.Migrations.CreateGameRecords do
  use Ecto.Migration

  def change do
    create table(:game_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :moves, :binary
      add :timings, :binary

      timestamps()
    end
  end
end
