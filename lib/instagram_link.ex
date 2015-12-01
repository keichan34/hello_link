defmodule InstagramLink do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(InstagramLink.Endpoint, []),
      # Start the Ecto repository
      worker(InstagramLink.Repo, []),
      worker(InstagramLink.Queue, []),
      worker(InstagramLink.QueueEvents, []),
      worker(InstagramLink.QueueProcessor, []),
      supervisor(InstagramLink.CrosspostSup, [])
    ]

    if instagram_client_id && instagram_client_secret do
      children = [worker(InstagramLink.InstagramStream, []) | children]
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InstagramLink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    InstagramLink.Endpoint.config_change(changed, removed)
    :ok
  end

  def instagram_client_id, do: Application.get_env(:instagram_link, :instagram_client_id)
  def instagram_client_secret, do: Application.get_env(:instagram_link, :instagram_client_secret)

  def adn_client_id, do: Application.get_env(:instagram_link, :adn_client_id)
  def adn_client_secret, do: Application.get_env(:instagram_link, :adn_client_secret)

  def instagram_callback_url,
    do: InstagramLink.Router.Helpers.instagram_callback_url(InstagramLink.Endpoint, :verify)
end
