defmodule AcasterWeb.MatchLive do
  use AcasterWeb, :live_view
  on_mount AcasterWeb.UserTokenAuth

  alias Acaster.MatcherServer

  def mount(_params, _session, socket) do
    case connected?(socket) do
      true -> {:ok, socket |> assign(fm_attr: [], tix: nil)}
      false -> {:ok, socket |> assign(fm_attr: [{:disabled, true}], tix: nil)}
    end
  end

  def handle_event("match", _params, socket) do
    IO.inspect("YEETUS")
    tix = MatcherServer.register(socket.assigns.current_user.id)
    IO.inspect(tix)
    {:noreply, socket |> assign(fm_attr: [], tix: tix.id)}
  end
end
