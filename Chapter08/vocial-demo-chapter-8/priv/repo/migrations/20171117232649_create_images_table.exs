defmodule Vocial.Repo.Migrations.CreateImagesTable do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :url, :string
      add :alt, :string
      add :caption, :string
      add :poll_id, references(:polls)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
