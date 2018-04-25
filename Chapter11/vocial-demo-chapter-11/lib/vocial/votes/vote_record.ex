defmodule Vocial.Votes.VoteRecord do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vocial.Votes.VoteRecord
  alias Vocial.Votes.Poll

  schema "vote_records" do
    field :ip_address, :string

    belongs_to :poll, Poll

    timestamps()
  end

  def changeset(%VoteRecord{}=vote_record, attrs) do
    vote_record
    |> cast(attrs, [:ip_address, :poll_id])
    |> validate_required([:ip_address, :poll_id])
  end
end