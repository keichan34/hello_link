defmodule HelloLink do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(HelloLink.Endpoint, []),
      # Start the Ecto repository
      worker(HelloLink.Repo, []),
      worker(HelloLink.Queue, []),
      worker(HelloLink.QueueEvents, []),
      worker(HelloLink.QueueProcessor, []),
      supervisor(HelloLink.CrosspostSup, [])
    ]

    if instagram_client_id && instagram_client_secret do
      children = children ++ [worker(HelloLink.InstagramStream, [])]
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloLink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloLink.Endpoint.config_change(changed, removed)
    :ok
  end

  def instagram_client_id, do: Application.get_env(:hello_link, :instagram_client_id)
  def instagram_client_secret, do: Application.get_env(:hello_link, :instagram_client_secret)

  def adn_client_id, do: Application.get_env(:hello_link, :adn_client_id)
  def adn_client_secret, do: Application.get_env(:hello_link, :adn_client_secret)

  def instagram_callback_url,
    do: HelloLink.Router.Helpers.instagram_callback_url(HelloLink.Endpoint, :verify)
end
