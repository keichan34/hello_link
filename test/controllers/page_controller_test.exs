defmodule HelloLink.PageControllerTest do
  use HelloLink.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Hello Link"
  end
end
