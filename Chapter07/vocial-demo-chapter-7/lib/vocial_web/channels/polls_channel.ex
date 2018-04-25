defmodule VocialWeb.PollsChannel do
  use VocialWeb, :channel

  def join("polls:" <> _poll_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("ping", _payload, socket) do
    broadcast socket, "pong", %{message: "pong"}
    {:reply, {:ok, %{message: "pong"}}, socket}
  end

  def handle_in("vote", %{"option_id" => option_id}, socket) do
    with {:ok, option} <- Vocial.Votes.vote_on_option(option_id) do
      broadcast socket, "new_vote", %{"option_id" => option.id, "votes" => option.votes}
      {:reply, {:ok, %{"option_id" => option.id, "votes" => option.votes}}, socket}
    else
      {:error, _} ->
        {:reply, {:error, %{message: "Failed to vote for option!"}}, socket}
    end
  end
end
