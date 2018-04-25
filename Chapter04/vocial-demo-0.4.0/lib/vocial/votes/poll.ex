defmodule Vocial.Votes.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.Poll
  alias Vocial.Votes.Option

  schema "polls" do
    field :title, :string

    has_many :options, Option

    timestamps()
  end

  def changeset(%Poll{}=poll, attrs) do
    poll
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
