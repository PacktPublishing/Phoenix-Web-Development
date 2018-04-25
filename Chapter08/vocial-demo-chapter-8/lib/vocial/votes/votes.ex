defmodule Vocial.Votes do
  import Ecto.Query, warn: false

  alias Vocial.Repo
  alias Vocial.Votes.Poll
  alias Vocial.Votes.Option
  alias Vocial.Votes.Image
  alias Vocial.Votes.VoteRecord
  alias Vocial.Votes.Message

  require IEx

  def get_poll(id), do: Repo.get!(Poll, id) |> Repo.preload([:options, :image, :vote_records, :messages])

  def list_polls do
    Repo.all(Poll) |> Repo.preload([:options, :image, :vote_records, :messages])
  end

  def new_poll do
    Poll.changeset(%Poll{}, %{})
  end

  def create_poll_with_options(poll_attrs, options) do
    create_poll_with_options(poll_attrs, options, nil)
  end

  def create_poll_with_options(poll_attrs, options, image_data) do
    Repo.transaction(fn ->
      with {:ok, poll} <- create_poll(poll_attrs),
           {:ok, _options} <- create_options(options, poll),
           {:ok, filename} <- upload_file(poll_attrs, poll),
           {:ok, _upload} <- save_upload(poll, image_data, filename)
      do
        poll |> Repo.preload([:options, :image])
      else
        _ -> Repo.rollback("Failed to create poll!")
      end
    end)
  end

  defp upload_file(%{"image" => image, "user_id" => user_id}, poll) do
    extension = Path.extname(image.filename)
    filename = "#{user_id}-#{poll.id}-image#{extension}"
    File.cp(image.path, "./uploads/#{filename}")
    {:ok, filename}
  end
  defp upload_file(_, _), do: {:ok, nil}

  defp save_upload(_poll, _image_data, nil), do: {:ok, nil}
  defp save_upload(poll, %{"caption" => caption, "alt_text" => alt_text}, filename) do
    attrs = %{
      url: "/uploads/#{filename}",
      alt: alt_text,
      caption: caption,
      poll_id: poll.id,
      user_id: poll.user_id
    }
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  def create_poll(attrs) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  def create_options(options, poll) do
    results = Enum.map(options, fn option ->
      create_option(%{title: option, poll_id: poll.id})
    end)

    if Enum.any?(results, fn {status, _} -> status == :error end) do
      {:error, "Failed to create an option"}
    else
      {:ok, results}
    end
  end

  def create_option(attrs) do
    %Option{}
    |> Option.changeset(attrs)
    |> Repo.insert()
  end

  def list_options do
    Repo.all(Option) |> Repo.preload(:poll)
  end

  def vote_on_option(option_id, voter_ip) do
    with option <- Repo.get!(Option, option_id),
         false <- already_voted?(option.poll_id, voter_ip),
         votes <- option.votes + 1,
         {:ok, option} <- update_option(option, %{votes: votes}),
         {:ok, _vote_record} <- record_vote(%{ poll_id: option.poll_id, ip_address: voter_ip })
    do
      {:ok, option}
    else
      _ -> {:error, "Could not place vote"}
    end
  end

  def update_option(option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
  end

  def record_vote(%{poll_id: _poll_id, ip_address: _ip_address}=attrs) do
    %VoteRecord{}
    |> VoteRecord.changeset(attrs)
    |> Repo.insert()
  end

  def already_voted?(poll_id, ip_address) do
    votes = (from vr in VoteRecord, where: vr.poll_id == ^poll_id and vr.ip_address == ^ip_address)
    |> Repo.aggregate(:count, :id)
    votes > 0
  end

  ## Message Functionality
  
  def list_lobby_messages do
    Repo.all(
      from m in Message,
      where: is_nil(m.poll_id),
      order_by: [desc: :inserted_at],
      limit: 100
    )
  end

  def list_poll_messages(poll_id) do
    Repo.all(
      from m in Message,
      where: m.poll_id == ^poll_id,
      order_by: [desc: :inserted_at],
      limit: 100,
      preload: [:poll]
    )
  end

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end
end
