defmodule VocialWeb.UserControllerTest do
  use VocialWeb.ConnCase

  @create_params %{
    "username" => "test",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  test "GET /users/new", %{conn: conn} do
    conn = get conn, "/users/new"
    response = html_response(conn, 200)
    assert response =~ "User Signup"
    assert conn.assigns.user.__struct__ == Ecto.Changeset
    assert response =~ "action=\"/users\" method=\"post\""
  end

  test "GET /users/:id", %{conn: conn} do
    with {:ok, user} <- Vocial.Accounts.create_user(@create_params) do
      conn = get conn, "/users/#{user.id}"
      assert html_response(conn, 200) =~ user.username
    else
      _ -> assert false
    end
  end

  test "POST /users", %{conn: conn} do
    conn = post conn, "/users", %{"user" => @create_params}
    assert redirected_to(conn) =~ "/users/"
  end
end
