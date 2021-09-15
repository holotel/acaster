defmodule Acaster.Game.Record do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "game_records" do
    field :moves, :binary
    field :timings, :binary

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:moves, :timings])
    |> validate_required([:id, :moves, :timings])
  end
end
