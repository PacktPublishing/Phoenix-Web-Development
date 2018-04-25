defmodule VocialWeb.PollChannelTest do
  use VocialWeb.ChannelCase

  alias VocialWeb.PollsChannel

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
    {:ok, _, socket} =
      socket("user_id", %{user_id: user.id})
      |> subscribe_and_join(PollsChannel, "polls:#{poll.id}")
    {:ok, socket: socket, user: user, poll: poll}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{}
    assert_reply ref, :ok, %{message: "pong"}
  end

  test "vote replies with status ok", %{socket: socket, poll: poll} do
    option = Enum.at(poll.options, 0)
    ref = push socket, "vote", %{"option_id" => option.id}

    assert_reply ref, :ok, %{"option_id" => option_id, "votes" => votes}
    assert option_id == option.id
    assert votes == option.votes + 1

    assert_broadcast "new_vote", %{"option_id" => option_id, "votes" => votes}
    assert option_id == option.id
    assert votes == option.votes + 1
  end
end
