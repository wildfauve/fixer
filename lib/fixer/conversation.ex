defmodule Fixer.Conversation do

  alias __MODULE__

  alias Fixer.{Act, Relationship}

  defstruct [:relationship, :state, :warehouse_key]

  def new(), do: %Conversation{state: :waiting_establishment}

  def add_relationship(conversation, relationship) do
    put_in(conversation.relationship, relationship)
    |> add_warehouse_key
    |> change_state
  end

  def say(convo, speaker, msg) do
    {:ok, update_in(convo.acts, fn x -> x ++ [Act.new(speaker, msg)] end)}
  end

  defp add_warehouse_key(conv) do
    put_in(conv.warehouse_key, Relationship.tokenise_relationship(conv.relationship))
  end

  defp change_state(conv) do
    {:ok, put_in(conv.state, transition(conv.relationship.state))}
  end

  def transition(:players_set), do: :established
  def transition(_), do: :waiting_establishment

end
