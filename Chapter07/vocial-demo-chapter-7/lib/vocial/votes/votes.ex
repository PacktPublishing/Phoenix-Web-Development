defmodule Vocial.Votes do
  import Ecto.Query, warn: false

  alias Vocial.Repo
  alias Vocial.Votes.Poll
  alias Vocial.Votes.Option
  alias Vocial.Votes.Image

  def get_poll(id), do: Repo.get!(Poll, id) |> Repo.preload([:options, :image])

  def list_polls do
    Repo.all(Poll) |> Repo.preload([:options, :image])
  end

  def new_poll do
    Poll.changeset(%Poll{}, %{})
  end

  def create_poll_with_options(poll_attrs, options, image_data) do
    Repo.transaction(fn ->
      with {:ok, poll} <- create_poll(poll_attrs),
           {:ok, _options} <- create_options(options, poll),
           {:ok, filename} <- upload_file(poll_attrs, poll),
           {:ok, _upload} <- save_upload(poll, image_data, filename)
      do
        poll |> Repo.preload(:options)
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

  def vote_on_option(option_id) do
    with option <- Repo.get!(Option, option_id),
         votes <- option.votes + 1
    do
      update_option(option, %{votes: votes})
    end
  end

  def update_option(option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
  end
end
