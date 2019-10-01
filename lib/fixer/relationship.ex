defmodule Fixer.Relationship do

  alias __MODULE__

  alias Fixer.Player

  defstruct [:receiver, :initiator, state: :waiting_players]

  def new(), do: %Relationship{}

  def add_player(%Relationship{} = relationship, player) do
    with {:ok, next_state} <-       valid_state(relationship, :add_player)
    do
      {:ok, %{relationship | player.role => player, state: next_state}}
    else
      {:error, error} -> {:error, error}
    end
  end

  def tokenise_relationship(relationship) do
    "#{relationship.initiator.host}-#{relationship.receiver.host}" |> String.to_atom
  end

  defp valid_state(%{state: :waiting_players} = rel, :add_player) do
    case {Map.get(rel, :initiator), Map.get(rel, :receiver)} do
      {nil, nil}                -> {:ok, :waiting_players}
      {%Player{},   nil}        -> {:ok, :players_set}
      {nil, %Player{}}          -> {:ok, :players_set}
      {%Player{},   %Player{}}  -> {:error, :players_already_set}
    end
  end
  defp valid_state(%{state: :players_set}, :add_player), do: {:error, :players_already_set}

end
