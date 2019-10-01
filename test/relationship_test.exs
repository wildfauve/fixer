defmodule RelationshipTest do
  use ExUnit.Case

  alias Fixer.{Relationship, Player}

  setup do
    {:ok, trader} = Player.new("player1", :trader)
    {:ok, client} = Player.new("player2", :client)
    {:ok, relationship} = Relationship.add_player(Relationship.new, trader)
    {:ok, relationship} = Relationship.add_player(relationship, client)

    %{relationship: relationship}
  end


  test "sets up a new relationship" do
    relationship = Relationship.new

    {:ok, client} = Map.fetch(relationship, :client)
    {:ok, trader} = Map.fetch(relationship, :trader)

    assert trader == nil
    assert client == nil
  end

  test "adds a player to the relationship" do
    {:ok, trader} = Player.new("player1", :trader)
    relationship = Relationship.new

    {:ok, relationship} = Relationship.add_player(relationship, trader)

    assert relationship.trader == trader
  end

  test "players become set when both have been added" do
    {:ok, trader} = Player.new("player1", :trader)
    {:ok, client} = Player.new("player2", :client)
    relationship = Relationship.new

    {:ok, relationship} = Relationship.add_player(relationship, trader)
    {:ok, relationship} = Relationship.add_player(relationship, client)

    assert relationship.state == :players_set

  end


end
