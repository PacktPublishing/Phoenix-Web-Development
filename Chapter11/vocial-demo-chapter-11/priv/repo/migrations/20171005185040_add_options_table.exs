defmodule Vocial.Repo.Migrations.AddOptionsTable do
  use Ecto.Migration

  def change do
    create table("options") do
      add :title, :string
      add :votes, :integer, default: 0
      add :poll_id, references(:polls)

      timestamps()
    end
  end
end
