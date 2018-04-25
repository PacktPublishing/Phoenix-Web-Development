defmodule Vocial.VotesTest do
  use Vocial.DataCase

  alias Vocial.Votes
  alias Vocial.Repo

  setup do
    {:ok, user} = Vocial.Accounts.create_user(%{
      username: "test",
      email: "test@test.com",
      password: "test",
      password_confirmation: "test"
    })
    {:ok, user: user}
  end

  describe "polls" do
    @valid_attrs %{ title: "Hello" }

    def poll_fixture(attrs \\ %{}) do
      with create_attrs <- Enum.into(attrs, @valid_attrs),
           {:ok, poll} <- Votes.create_poll(create_attrs),
           poll <- Repo.preload(poll, :options)
      do
        poll
      end
    end

    test "show_poll/1 returns a specific poll", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.get_poll(poll.id) == poll
    end

    test "list_polls/0 returns all polls", %{user: user} do
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.list_polls() == [poll]
    end

    test "new_poll/0 returns a new blank changeset" do
      changeset = Votes.new_poll()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_poll/1 returns a new poll", %{user: user} do
      {:ok, poll} = Votes.create_poll(Map.put(@valid_attrs, :user_id, user.id))
      assert Enum.any?(Votes.list_polls(), fn p -> p.id == poll.id end)
    end

    test "create_poll_with_options/2 returns a new poll with options", %{user: user} do
      title = "Poll With Options"
      options = ["Choice 1", "Choice 2", "Choice 3"]
      {:ok, poll} = Votes.create_poll_with_options(%{title: title, user_id: user.id}, options)
      assert poll.title == title
      assert Enum.count(poll.options) == 3
    end

    test "create_poll_with_options/2 does not create the poll or options with bad data", %{user: user} do
      title = "Bad Poll"
      options = ["Choice 1", nil, "Choice 3"]
      {status, _} = Votes.create_poll_with_options(%{title: title, user_id: user.id}, options)
      assert status == :error
      assert !Enum.any?(Votes.list_polls(), fn p -> p.title == "Bad Poll" end)
    end
  end

  describe "options" do
    test "create_option/1 creates an option on a poll", %{user: user} do
      with {:ok, poll} = Votes.create_poll(%{ title: "Sample Poll", user_id: user.id }),
           {:ok, option} = Votes.create_option(%{ title: "Sample Choice", votes: 0, poll_id: poll.id }),
           option <- Repo.preload(option, :poll)
      do
        assert Votes.list_options() == [option]
      end
    end

    test "vote_on_option/1 adds a vote to a particular option", %{user: user} do
      with {:ok, poll} = Votes.create_poll(%{ title: "Sample Poll", user_id: user.id }),
           {:ok, option} = Votes.create_option(%{ title: "Sample Choice", votes: 0, poll_id: poll.id }),
           option <- Repo.preload(option, :poll)
      do
        votes_before = option.votes
        {:ok, updated_option} = Votes.vote_on_option(option.id)
        assert (votes_before + 1) == updated_option.votes
      end
    end
  end
end
