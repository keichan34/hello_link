defmodule InstagramLink.User do
  use InstagramLink.Web, :model

  schema "users" do
    field :instagram_uid, :string
    field :adn_uid, :string

    field :instagram_token, :string
    field :adn_token, :string

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(instagram_uid adn_uid instagram_token adn_token)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def is_linked_to_instagram?(%User{} = user) do
    !!user.instagram_uid
  end
  def is_linked_to_instagram?(nil), do: false

  def is_linked_to_adn?(%User{} = user) do
    !!user.adn_uid
  end
  def is_linked_to_adn?(nil), do: false
end
