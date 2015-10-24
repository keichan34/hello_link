defmodule InstagramLink.AuthController do
  use InstagramLink.Web, :controller

  def instagram(conn, _params) do
    query = %{
      client_id: InstagramLink.instagram_client_id,
      redirect_uri: auth_callback_url(InstagramLink.Endpoint, :instagram),
      response_type: "code"
    } |> URI.encode_query
    redirect conn, external: "https://api.instagram.com/oauth/authorize/?#{query}"
  end

  def adn(conn, _params) do
    query = %{
      client_id: InstagramLink.adn_client_id,
      redirect_uri: auth_callback_url(InstagramLink.Endpoint, :adn),
      response_type: "code",
      scope: "write_post"
    } |> URI.encode_query
    redirect conn, external: "https://account.app.net/oauth/authenticate?#{query}"
  end

  def deauth_instagram(%{assigns: %{user: user}} = conn, _params) when not is_nil(user) do
    user
    |> User.changeset(%{
      instagram_uid: nil,
      instagram_token: nil,
      instagram_username: nil
    })
    |> Repo.update

    redirect conn, to: "/"
  end

  def deauth_adn(%{assigns: %{user: user}} = conn, _params) when not is_nil(user) do
    user
    |> User.changeset(%{
      adn_uid: nil,
      adn_token: nil,
      adn_username: nil
    })
    |> Repo.update

    redirect conn, to: "/"
  end
end
