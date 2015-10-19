defmodule InstagramLink.PageController do
  use InstagramLink.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
