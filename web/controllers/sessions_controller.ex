defmodule HelloLink.SessionsController do
  use HelloLink.Web, :controller

  def destroy(conn, _params) do
    conn
    |> assign(:user, nil)
    |> put_session(:user_id, nil)
    |> put_flash(:info, "You have been logged out. Click one of the \"Authorize\" buttons to log back in.")
    |> redirect(to: "/")
  end
end
