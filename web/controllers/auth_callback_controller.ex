defmodule InstagramLink.AuthCallbackController do
  use InstagramLink.Web, :controller

  alias InstagramLink.InstagramApi
  alias InstagramLink.AdnAccountApi

  def instagram(conn, %{"code" => code} = _params) do
    conn
    |> get_user_from_instagram_code(code)
    |> redirect to: "/"
  end

  def adn(conn, %{"code" => code} = _params) do
    conn
    |> get_user_from_adn_code(code)
    |> redirect to: "/"
  end

  defp get_user_from_instagram_code(conn, code) do
    body = %{
      client_id: InstagramLink.instagram_client_id,
      client_secret: InstagramLink.instagram_client_secret,
      grant_type: "authorization_code",
      redirect_uri: auth_callback_url(InstagramLink.Endpoint, :instagram),
      code: code
    } |> URI.encode_query

    case InstagramApi.post("/oauth/access_token", body) do
      {:ok, %HTTPoison.Response{body: response}} ->
        fetch_or_create_user(conn, response)
    end
  end

  defp fetch_or_create_user(conn, %{"access_token" => token, "user" => %{"id" => uid}}) do
    fetch_or_create_user(conn, token, uid, :instagram)
  end

  defp fetch_or_create_user(conn, %{"access_token" => token, "token" => %{"user" => %{"id" => uid }}}) do
    fetch_or_create_user(conn, token, uid, :adn)
  end

  defp fetch_or_create_user(%Plug.Conn{assigns: %{user: nil}} = conn, token, uid, service) do
    user = case Repo.get_by(User, [{:"#{service}_uid", uid}]) do
      nil ->
        changeset = User.changeset(%User{}, [{:"#{service}_uid", uid}, {:"#{service}_token", token}] |> Enum.into(%{}))
        {:ok, user} = Repo.insert(changeset)
        user
      user ->
        changeset = User.changeset(user, [{:"#{service}_token", token}] |> Enum.into(%{}))
        {:ok, user} = Repo.update(changeset)
        user
    end

    conn
    |> assign(:user, user)
    |> put_session(:user_id, user.id)
  end

  defp fetch_or_create_user(%Plug.Conn{assigns: %{user: user}} = conn, token, uid, service) do
    changeset = User.changeset(user, [{:"#{service}_uid", uid}, {:"#{service}_token", token}] |> Enum.into(%{}))
    {:ok, user} = Repo.update(changeset)

    conn
    |> assign(:user, user)
  end

  defp get_user_from_adn_code(conn, code) do
    body = %{
      client_id: InstagramLink.adn_client_id,
      client_secret: InstagramLink.adn_client_secret,
      grant_type: "authorization_code",
      redirect_uri: auth_callback_url(InstagramLink.Endpoint, :adn),
      code: code
    } |> URI.encode_query

    case AdnAccountApi.post("/oauth/access_token", body, [{:"content-type", "application/x-www-form-urlencoded"}]) do
      {:ok, %HTTPoison.Response{body: response}} ->
        fetch_or_create_user(conn, response)
    end
  end
end
