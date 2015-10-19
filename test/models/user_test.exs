defmodule InstagramLink.UserTest do
  use InstagramLink.ModelCase

  alias InstagramLink.User

  @valid_attrs %{adn_uid: "some content", instagram_uid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
