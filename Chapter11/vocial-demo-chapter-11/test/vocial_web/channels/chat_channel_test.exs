defmodule VocialWeb.ChatChannelTest do
  use VocialWeb.ChannelCase

  alias VocialWeb.ChatChannel

  setup do
    {:ok, user} = Vocial.Accounts.create_user(%{
      username: "test",
      email: "test@test.com",
      password: "test",
      password_confirmation: "test"
    })
    {:ok, poll} = Vocial.Votes.create_poll_with_options(
      %{ "title" => "My New Test Poll", "user_id" => user.id },
      ["One", "Two", "Three"]
    )
    socket = socket("user_id", %{user_id: user.id})
    {:ok, _, poll_socket} = subscribe_and_join(socket, ChatChannel, "chat:#{poll.id}", %{})
    {:ok, _, lobby_socket} = subscribe_and_join(socket, ChatChannel, "chat:lobby", %{})
    {:ok, poll_socket: poll_socket, lobby_socket: lobby_socket, user: user, poll: poll}
  end

  test "new_message replies with status ok for chat:poll_id", %{poll_socket: socket} do
    ref = push socket, "new_message", %{"author" => "test", "message" => "Hello World"}
    assert_reply ref, :ok, %{author: author, message: message}
    assert author == "test"
    assert message == "Hello World"

    assert_broadcast "new_message", %{author: author, message: message}
    assert author == "test"
    assert message == "Hello World"
  end

  test "new_message replies with status ok for chat:lobby", %{lobby_socket: socket} do
    ref = push socket, "new_message", %{"author" => "test", "message" => "Hello World"}
    assert_reply ref, :ok, %{author: author, message: message}
    assert author == "test"
    assert message == "Hello World"

    assert_broadcast "new_message", %{author: author, message: message}
    assert author == "test"
    assert message == "Hello World"
  end
end
