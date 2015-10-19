defmodule InstagramLink.UserSession do
  import Plug.Conn

  alias InstagramLink.Repo
  alias InstagramLink.User

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    assign(conn, :user, fetch_user(conn))
  end

  defp fetch_user(conn) do
    user_id = conn |> fetch_session |> get_session(:user_id)
    if user_id do
      Repo.get(User, user_id)
    else
      nil
    end
  end
end
