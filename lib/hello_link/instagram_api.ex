defmodule HelloLink.InstagramApi do
  use HTTPoison.Base

  require Logger

  def process_url(url) do
    "https://api.instagram.com" <> url
  end

  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, out} ->
        out
      {:error, err} ->
        Logger.error "Received error decoding JSON: #{inspect err} (source: '#{inspect body}')"
        %{}
    end
  end
end
