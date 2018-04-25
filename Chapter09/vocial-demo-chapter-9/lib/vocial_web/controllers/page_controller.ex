defmodule VocialWeb.PageController do
  use VocialWeb, :controller

  alias Vocial.Votes

  alias Vocial.ChatCache

  require IEx

  def index(conn, _params) do
    messages = Votes.list_lobby_messages() |> Enum.reverse()
    render conn, "index.html", messages: messages
  end

  def history(conn, _params) do
    render conn, "history.html", logs: ChatCache.lookup()
  end
end
