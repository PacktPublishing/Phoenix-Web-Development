defmodule Vocial.VotesTest do
  use Vocial.DataCase

  alias Vocial.Votes
  alias Vocial.Repo

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

    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Votes.list_polls() == [poll]
    end

    test "new_poll/0 returns a new blank changeset" do
      changeset = Votes.new_poll()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_poll/1 returns a new poll" do
      {:ok, poll} = Votes.create_poll(@valid_attrs)
      assert Enum.any?(Votes.list_polls(), fn p -> p.id == poll.id end)
    end

    test "create_poll_with_options/2 returns a new poll with options" do
      title = "Poll With Options"
      options = ["Choice 1", "Choice 2", "Choice 3"]
      {:ok, poll} = Votes.create_poll_with_options(%{title: title}, options)
      assert poll.title == title
      assert Enum.count(poll.options) == 3
    end

    test "create_poll_with_options/2 does not create the poll or options with bad data" do
      title = "Bad Poll"
      options = ["Choice 1", nil, "Choice 3"]
      {status, _} = Votes.create_poll_with_options(%{title: title}, options)
      assert status == :error
      assert !Enum.any?(Votes.list_polls(), fn p -> p.title == "Bad Poll" end)
    end
  end

  describe "options" do
    test "create_option/1 creates an option on a poll" do
      with {:ok, poll} = Votes.create_poll(%{ title: "Sample Poll" }),
           {:ok, option} = Votes.create_option(%{ title: "Sample Choice", votes: 0, poll_id: poll.id }),
           option <- Repo.preload(option, :poll)
      do
        assert Votes.list_options() == [option]
      end
    end
  end
end
