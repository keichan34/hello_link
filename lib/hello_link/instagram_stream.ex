defmodule HelloLink.InstagramStream do
  use GenServer

  alias HelloLink.InstagramApi

  require Logger

  # Refresh the stream subscription every 24 hours.
  @refresh_interval 86_400_000

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Remove notification endpoints that do not apply anymore. Compares against the
  callback_url
  """
  def cleanup() do
    GenServer.cast(__MODULE__, :cleanup)
  end

  def init(:ok) do
    Kernel.send self, :initialize

    {:ok, %{
      token: "aoeuaoeu",
      stream_id: nil,
      refresh_timer: nil
    }}
  end

  def handle_info(:initialize, state) do
    state = enqueue_refresh_timer(state)
    handle_info(:do_refresh, state)
  end

  def handle_info(:do_refresh, %{token: token} = state) do
    body = %{
      client_id: HelloLink.instagram_client_id,
      client_secret: HelloLink.instagram_client_secret,
      object: "user",
      aspect: "media",
      verify_token: token,
      callback_url: HelloLink.instagram_callback_url
    } |> URI.encode_query

    case InstagramApi.post("/v1/subscriptions/", body, [{:"content-type", "application/x-www-form-urlencoded"}]) do
      {:ok, %HTTPoison.Response{body: response}} ->
        subscription = response["data"]
        id = subscription["id"]
        state = put_in(state.stream_id, id)
    end

    {:noreply, state}
  end

  def handle_cast(:cleanup, state) do
    query = %{
      client_id: HelloLink.instagram_client_id,
      client_secret: HelloLink.instagram_client_secret
    } |> URI.encode_query

    case InstagramApi.get("/v1/subscriptions?#{query}") do
      {:ok, %HTTPoison.Response{body: response}} ->
        response["data"]
        |> Enum.filter(fn(%{"callback_url" => url}) -> url != HelloLink.instagram_callback_url end)
        |> Enum.each(&remove_subscription/1)
    end

    {:noreply, state}
  end

  defp enqueue_refresh_timer(state, timeout \\ @refresh_interval) do
    %{state | refresh_timer: Process.send_after(self(), :do_refresh, timeout)}
  end

  defp remove_subscription(%{"id" => id}) do
    query = %{
      client_id: HelloLink.instagram_client_id,
      client_secret: HelloLink.instagram_client_secret,
      id: id
    } |> URI.encode_query

    {:ok, _} = InstagramApi.delete("/v1/subscriptions?#{query}")
    Logger.info "Deleted Instagram subscription ##{id}"
  end
end
