defmodule Acaster.Repo do
  use Ecto.Repo,
    otp_app: :acaster,
    adapter: Ecto.Adapters.Postgres
end
