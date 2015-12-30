defmodule HelloLink.AuthCallbackController do
  use HelloLink.Web, :controller

  alias HelloLink.InstagramApi
  alias HelloLink.AdnAccountApi

  require Logger

  def instagram(conn, %{"code" => code} = _params) do
    conn
    |> get_user_from_code({:instagram, code})
    |> redirect to: "/"
  end

  def adn(conn, %{"code" => code} = _params) do
    conn
    |> get_user_from_code({:adn, code})
    |> redirect to: "/"
  end

  defp get_user_from_code(conn, {:instagram, code}) do
    body = %{
      client_id: HelloLink.instagram_client_id,
      client_secret: HelloLink.instagram_client_secret,
      grant_type: "authorization_code",
      redirect_uri: auth_callback_url(HelloLink.Endpoint, :instagram),
      code: code
    } |> URI.encode_query

    case InstagramApi.post("/oauth/access_token", body) do
      {:ok, %HTTPoison.Response{body: response}} ->
        params = prepare_user_params({:instagram, response})
        fetch_or_create_user(conn, {:instagram, params})
    end
  end

  defp get_user_from_code(conn, {:adn, code}) do
    body = %{
      client_id: HelloLink.adn_client_id,
      client_secret: HelloLink.adn_client_secret,
      grant_type: "authorization_code",
      redirect_uri: auth_callback_url(HelloLink.Endpoint, :adn),
      code: code
    } |> URI.encode_query

    case AdnAccountApi.post("/oauth/access_token", body, [{:"content-type", "application/x-www-form-urlencoded"}]) do
      {:ok, %HTTPoison.Response{body: response}} ->
        params = prepare_user_params({:adn, response})
        fetch_or_create_user(conn, {:adn, params})
    end
  end

  defp prepare_user_params({:instagram, response}) do
    [
      token: response["access_token"],
      uid: response["user"]["id"],
      username: response["user"]["username"]
    ]
  end

  defp prepare_user_params({:adn, response}) do
    [
      token: response["access_token"],
      uid: response["token"]["user"]["id"],
      username: response["token"]["user"]["username"]
    ]
  end

  defp fetch_or_create_user(%Plug.Conn{assigns: %{user: nil}} = conn, service_params) do
    changes = service_params |> transform_service_params |> Enum.into(%{})
    user = case Repo.get_by(User, extract_service_params(service_params, [:uid])) do
      nil ->
        changeset = User.changeset(%User{}, changes)
        {:ok, user} = Repo.insert(changeset)
        user
      user ->
        changeset = User.changeset(user, changes)
        {:ok, user} = Repo.update(changeset)
        user
    end

    conn
    |> assign(:user, user)
    |> put_session(:user_id, user.id)
  end

  defp fetch_or_create_user(%Plug.Conn{assigns: %{user: user}} = conn, service_params) do
    changes = service_params |> transform_service_params |> Enum.into(%{})
    changeset = User.changeset(user, changes)
    {:ok, user} = Repo.update(changeset)

    conn
    |> assign(:user, user)
  end

  defp transform_service_params({service, params}) do
    params
    |>  Enum.map(fn({key, value}) ->
          {:"#{service}_#{key}", value}
        end)
  end

  defp extract_service_params({service, params}, keys) do
    params = Enum.filter(params, fn({key, _}) ->
      Enum.member?(keys, key)
    end)
    transform_service_params({service, params})
  end
end
