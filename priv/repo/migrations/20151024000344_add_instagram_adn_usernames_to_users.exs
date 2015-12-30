defmodule HelloLink.Repo.Migrations.AddInstagramAdnUsernamesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :instagram_username, :string
      add :adn_username, :string
    end
  end
end
