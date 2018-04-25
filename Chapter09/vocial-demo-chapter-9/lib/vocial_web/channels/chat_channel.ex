defmodule VocialWeb.ChatChannel do
  use VocialWeb, :channel

  alias Vocial.Votes
  alias VocialWeb.Presence

  alias Vocial.ChatCache

  require IEx

  def join("chat:lobby", payload, socket) do
    socket = assign(socket, :username, payload["username"])
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("chat:" <> _poll_id, payload, socket) do
    socket = assign(socket, :username, payload["username"])
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("new_message", %{"author" => author, "message" => message}, socket) do
    poll_id = case socket.topic do
      "chat:lobby" -> nil
      "chat:" <> id -> id
      _ -> nil
    end
    with {:ok, _message} <- Votes.create_message(%{author: author, message: message, poll_id: poll_id}) do
      broadcast socket, "new_message", %{author: author, message: message}
      {:reply, {:ok, %{author: author, message: message}}, socket}
    else
      _ -> {:reply, {:error, %{message: "Failed to send chat message"}}, socket}
    end
  end

  def handle_in("user_idle", %{"username" => username}, socket) do
    ChatCache.write(socket.topic, username, "idle")
    push socket, "presence_diff", Presence.list(socket)
    {:ok, _} = Presence.update(socket, username, %{
      status: "idle"
    })
    {:noreply, socket}
  end

  def handle_in("user_active", %{"username" => username}, socket) do
    presence = Presence.list(socket)
    [meta | _] = presence[username].metas
    if meta.status == "idle" do
      ChatCache.write(socket.topic, username, "active")
      push socket, "presence_diff", Presence.list(socket)
      {:ok, _} = Presence.update(socket, username, %{
        online_at: inspect(System.system_time(:seconds)),
        status: "active"
      })
    end
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    ChatCache.write(socket.topic, socket.assigns.username, "active")
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{
      online_at: inspect(System.system_time(:seconds)),
      status: "active"
    })
    {:noreply, socket}
  end
end