defmodule Vocial.Repo.Migrations.AddMessagesTable do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :message, :string
      add :author, :string
      add :poll_id, references(:polls)

      timestamps()
    end
    create index(:messages, [:poll_id])
  end
end
