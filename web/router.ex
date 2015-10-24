defmodule InstagramLink.Router do
  use InstagramLink.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InstagramLink do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/auth/instagram", AuthController, :instagram
    delete "/auth/instagram", AuthController, :deauth_instagram
    get "/auth/adn", AuthController, :adn
    delete "/auth/adn", AuthController, :deauth_adn

    get "/auth/instagram/callback", AuthCallbackController, :instagram
    get "/auth/adn/callback", AuthCallbackController, :adn

    delete "/session", SessionsController, :destroy
  end

  scope "/", InstagramLink do
    pipe_through :api

    get "/instagram-callback", InstagramCallbackController, :verify
    post "/instagram-callback", InstagramCallbackController, :process
  end
end
