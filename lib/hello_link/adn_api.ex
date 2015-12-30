defmodule HelloLink.AdnApi do
  use HTTPoison.Base

  def process_url(url) do
    "https://api.app.net" <> url
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end

  def process_request_body(body) do
    Poison.encode!(body)
  end

  def process_request_headers(headers) do
    [{"content-type", "application/json"} | headers]
  end
end
