defmodule VocialWeb.VerifyUserSession do
  import Plug.Conn, only: [get_session: 2, halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user) do
      nil ->
        conn
        |> put_flash(:error, "You must be logged in to do that!")
        |> redirect(to: "/")
        |> halt()
      _ -> conn
    end
  end
end
