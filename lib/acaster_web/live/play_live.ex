defmodule AcasterWeb.PlayLive do
  use AcasterWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    {:ok, socket |> assign(:id, id)}
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:id, "noid")}
  end
end
