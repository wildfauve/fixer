defmodule Fixer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:message_warehouse, [:public, :named_table])
    config = Application.get_env(:session, :server)

    children = [
      # Starts a worker by calling: Fixer.Worker.start_link(arg)
      # {Fixer.Worker, arg}
      {Registry, keys: :unique, name: Registry.Session},
      {Fixer.Session2, config}
      # {Fixer.Session, config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fixer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
