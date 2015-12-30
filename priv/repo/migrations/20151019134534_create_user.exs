defmodule HelloLink.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :instagram_uid, :string
      add :instagram_token, :string
      add :adn_uid, :string
      add :adn_token, :string

      timestamps
    end

    create index(:users, [:instagram_uid], unique: true)
    create index(:users, [:adn_uid], unique: true)
  end
end
