defmodule VocialWeb.PageController do
  use VocialWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
