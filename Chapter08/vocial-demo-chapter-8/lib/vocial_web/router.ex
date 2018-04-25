defmodule VocialWeb.Router do
  use VocialWeb, :router

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

  scope "/", VocialWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/votes", VoteController, only: [:index, :new, :create, :show]
    resources "/users", UserController, only: [:new, :show, :create]
    resources "/sessions", SessionController, only: [:create]
    get "/options/:id/vote", VoteController, :vote

    get "/login", SessionController, :new
    get "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", VocialWeb do
  #   pipe_through :api
  # end
end
