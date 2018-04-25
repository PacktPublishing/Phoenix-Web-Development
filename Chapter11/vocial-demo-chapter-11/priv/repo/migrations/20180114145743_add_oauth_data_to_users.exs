defmodule Vocial.Repo.Migrations.AddOauthDataToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :oauth_provider, :string
      add :oauth_id, :string
    end
  end
end
