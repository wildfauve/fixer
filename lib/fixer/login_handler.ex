defmodule Fixer.LoginHandler do

  require Logger

  alias Fixer.{Player, PlayerDirectory, Conversation, Relationship, Message}

  def handle(message, conversation, socket, transport) do
    login(message, conversation, socket, transport)
  end

  defp login(message, conversation, socket, transport) do
    with sub_id               <- from_message(message, "SenderSubID"),
         {:ok, initiator}     <- Player.new(sub_id, :initiator, from_message(message, "SenderCompID")),
         {:ok, receiver}      <- Player.new(PlayerDirectory.name_from_host(from_message(message, "TargetCompID")), :receiver, from_message(message, "TargetCompID")),
         {:ok, relationship}  <- Relationship.add_player(Relationship.new, receiver),
         {:ok, relationship}  <- Relationship.add_player(relationship, initiator),
         {:ok, conversation}  <- Conversation.add_relationship(conversation, relationship)
    do
      register_socket(sub_id, socket, transport)
      :ets.insert(:message_warehouse, {conversation.warehouse_key, message})
      {:ok, conversation, "OK\n"}
    end
  end

  def register_socket(key, socket, transport) do
    Logger.debug("[MessageFactory] register_socket token: #{key}")

    case Registry.register(Registry.Session, key, {socket, transport}) do
      {:error, {:already_registered, _pid}} -> Registry.update_value(Registry.Session, key, fn (_) -> {socket, transport} end)
      {:error, reason}                      -> Logger.error("[MessageFactory] reason: #{inspect(reason)}")
      _                                     -> {:ok}
    end
  end

  defp from_message(message, field) do
    [_name, value] = Message.find_by_field_name(message, field)
    value
  end


end
