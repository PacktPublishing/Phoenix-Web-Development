defmodule Vocial.Repo.Migrations.AddPollsTable do
  use Ecto.Migration

  def change do
    create table("polls") do
      add :title, :string

      timestamps()
    end
  end
end
