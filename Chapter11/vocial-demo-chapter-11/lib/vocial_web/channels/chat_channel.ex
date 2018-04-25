defmodule VocialWeb.ChatChannel do
  use VocialWeb, :channel

  alias Vocial.Votes
  alias VocialWeb.Presence

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

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end
end