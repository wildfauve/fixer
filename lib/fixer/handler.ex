defmodule Fixer.Handler do
  @moduledoc """
  A simple TCP protocol handler that echoes all messages received.
  """

  alias Fixer.{Message, MessageFactory, Conversation}

  use GenServer

  require Logger

  # Client

  @doc """
  Starts the handler with `:proc_lib.spawn_link/3`.  spawns the process asynchronously
  """
  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    Logger.debug("[Handler] start_link #{inspect(pid)}")
    {:ok, pid}
  end

  @doc """
  Initiates the handler, acknowledging the connection was accepted.
  Finally it makes the existing process into a `:gen_server` process and
  enters the `:gen_server` receive loop with `:gen_server.enter_loop/3`.
  """
  def init(ref, socket, transport) do
    peername = stringify_peername(socket)

    Logger.info(fn ->
      "Peer #{peername} connecting, socket: #{inspect(socket)}"
    end)

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])

    :gen_server.enter_loop(__MODULE__, [], %{
      socket: socket,
      transport: transport,
      peername: peername,
      conversation: Conversation.new
    })
  end

  # Server callbacks

  def handle_info({:tcp, _, message}, %{socket: socket, transport: transport, peername: peername, conversation: conversation} = state) do
    Logger.info(fn ->
      "Received new message from peer #{peername}: #{inspect(message)}"
    end)

    require IEx
    IEx.pry()

    # or message |> String.replace("\r", "") |> String.replace("\n", "")
    with {:ok, message}                 <- Message.new(String.trim(message, "\r\n")),
         {:ok, handler}                 <- MessageFactory.new(message, conversation, socket, transport),
         {:ok, conversation, response}  <- handler.()
    do
      transport.send(socket, response)
      {:noreply, put_in(state.conversation, conversation)}
    else
      {:error, response}  -> transport.send(socket, response)
                             {:noreply, state}
    end
  end

  def handle_info({:tcp_closed, _}, %{peername: peername} = state) do
    Logger.info(fn ->
      "Peer #{peername} disconnected"
    end)

    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _, reason}, %{peername: peername} = state) do
    Logger.info(fn ->
      "Error with peer #{peername}: #{inspect(reason)}"
    end)

    {:stop, :normal, state}
  end

  # Helpers

  defp stringify_peername(socket) do
    {:ok, {addr, port}} = :inet.peername(socket)

    address =
      addr
      |> :inet_parse.ntoa()
      |> to_string()

    "#{address}:#{port}"
  end

  def via(key), do: {:via, Registry, {Registry.Session, key}}
end
