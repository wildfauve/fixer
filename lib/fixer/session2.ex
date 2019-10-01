defmodule Fixer.Session2 do
  @moduledoc """
  A simple TCP server.
  """
  use GenServer

  alias Fixer.Handler

  require Logger

  @doc """
  Starts the server.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initiates the listener (pool of acceptors).
  """
  def init(port: port, ip: _ip) do
    opts = [{:port, port}]

    {:ok, pid} = :ranch.start_listener(:session, :ranch_tcp, opts, Handler, [])

    Logger.info(fn ->
      "Listening for connections on port #{port}"
    end)

    {:ok, pid}
  end
end
