defmodule Vocial.Repo.Migrations.AddVoteRecordsTable do
  use Ecto.Migration

  def change do
    create table(:vote_records) do
      add :ip_address, :string
      add :poll_id, references(:polls)

      timestamps()
    end
  end
end
