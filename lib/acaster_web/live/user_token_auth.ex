defmodule AcasterWeb.UserTokenAuth do
  import Phoenix.LiveView

  def mount(_params, %{"user_token" => user_token}, socket) do
    case Acaster.Accounts.get_user_by_session_token(user_token) do
      nil -> {:halt, redirect(socket, to: "/login")}
      user -> {:cont, socket |> assign(current_user: user)}
    end
  end

  def mount(_params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end
end
