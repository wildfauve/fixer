defmodule Fixer.MessageFactory do

  require Logger

  alias Fixer.{Message, Conversation, LoginHandler}

  def new(%Message{type: :login} = message, %Conversation{state: :waiting_establishment} = conversation, socket, transport) do
    {:ok, fn -> LoginHandler.handle(message, conversation, socket, transport) end}
  end
  def new(%Message{type: :login}, %Conversation{state: :established}, _socket, _transport) do
    {:error, "already logged in\n"}
  end
  def new(msg, _relationship, _socket, _transport) do
    {:error, "Sorry, dont understand; All I see is a #{msg}\n"}
  end

end
