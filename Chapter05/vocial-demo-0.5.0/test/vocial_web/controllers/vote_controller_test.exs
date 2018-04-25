defmodule VocialWeb.VoteControllerTest do
  use VocialWeb.ConnCase

  setup do
    conn = build_conn()
    {:ok, user} = Vocial.Accounts.create_user(%{
      username: "test",
      email: "test@test.com",
      password: "test",
      password_confirmation: "test"
    })
    {:ok, conn: conn, user: user}
  end

  defp login(conn, user) do
    conn |> post("/sessions", %{username: user.username, password: user.password})
  end

  test "GET /votes", %{conn: conn} do
    conn = get conn, "/votes"
    assert html_response(conn, 200)
  end

  test "GET /votes/new with a logged in user", %{conn: conn, user: user} do
    conn = login(conn, user) |> get("/votes/new")
    assert html_response(conn, 200) =~ "New Poll"
  end

  test "GET /votes/new without a logged in user", %{conn: conn} do
    conn = get(conn, "/votes/new")
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) == "You must be logged in to do that!"
  end

  test "POST /votes (with valid data)", %{conn: conn, user: user} do
    conn = login(conn, user)
      |> post("/votes", %{"poll" => %{ "title" => "Test Poll" }, "options" => "One,Two,Three" })
    assert redirected_to(conn) == "/votes"
  end

  test "POST /votes (with valid data, without logged in user)", %{conn: conn} do
    conn = post(conn, "/votes", %{"poll" => %{ "title" => "Test Poll" }, "options" => "One,Two,Three" })
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :error) == "You must be logged in to do that!"
  end

  test "POST /votes (with invalid data)", %{conn: conn, user: user} do
    conn = login(conn, user)
      |> post("/votes", %{"poll" => %{ title: nil }, "options" => "One,Two,Three" })
    assert html_response(conn, 302)
    assert redirected_to(conn) == "/votes/new"
  end
end
