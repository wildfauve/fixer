defmodule Fixer.Session do

  require Logger

  alias Fixer.MessageFactory

  """
  Client Side:
  :gen_tcp.recv(socket,0,1000)

  Server Side:
  {:ok, socket} = :gen_tcp.listen(8080, [:binary, packet: :line, active: false, reuseaddr: true])
  {:ok, client} = :gen_tcp.accept(socket)
  """

  # @ip     {127,0,0,1}
  # @port   8000
  use GenServer

  #
  # Client Functions
  #
  def start_link([port: port, ip: ip]) do
    # ip = Application.get_env(:fix_tcp, :ip, {127,0,0,1})
    # port = Application.get_env(:fix_tcp, :port, 8000)
    GenServer.start_link(__MODULE__, {ip, port}, [])
  end

  def login(session) do
    GenServer.call(session, :login)
  end

  #
  # Callback Functions
  #
  def init {ip, port} do
    Logger.debug("[session] starting server on port :#{port}")
    {:ok,listen_socket} = :gen_tcp.listen(port,[:binary,{:packet, 0},{:active,true},{:ip,ip}])
    {:ok,socket } = :gen_tcp.accept listen_socket
    {:ok, %{ip: ip, port: port, socket: socket}}
  end

  def handle_call(:login, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:tcp, socket, packet}, state) do
    Logger.debug("[Session] #{packet}")

    {:ok, response} = MessageFactory.new(String.trim(packet, "\r\n"), socket)

    :gen_tcp.send(socket, response)
    {:noreply, state}
  end
  def handle_info({:tcp_closed,socket}, state) do
    Logger.debug("[Session] Socket has been closed")
    {:noreply, state}
  end
  def handle_info({:tcp_error, socket, reason}, state) do
    IO.inspect(socket,label: "connection closed due to #{reason}")
    {:noreply, state}
  end

end
