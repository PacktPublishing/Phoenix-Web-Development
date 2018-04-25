defmodule VocialWeb.PageController do
  use VocialWeb, :controller

  alias Vocial.Votes

  def index(conn, _params) do
    messages = Votes.list_lobby_messages() |> Enum.reverse()
    render conn, "index.html", messages: messages
  end
end
