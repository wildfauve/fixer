defmodule RelationshipTest do
  use ExUnit.Case

  alias Fixer.{Conversation, Relationship, Player, Message}

  setup do
    {:ok, trader} = Player.new("player1", :trader)
    {:ok, client} = Player.new("player2", :client)
    {:ok, relationship} = Relationship.add_player(Relationship.new, trader)
    {:ok, relationship} = Relationship.add_player(relationship, client)
    msg = "8=FIX.4.2|9=97|35=8|6=10|11=12345|14=100|17=1|20=0|31=10|32=100|37=1|38=100|39=2|54=1|55=BHP|100=AX|150=2|151=0|10=038"

    {:ok, msg} = Message.new(msg)

    %{relationship: relationship, msg: msg}
  end

  test "player 1 speaks to player 2", %{relationship: relationship, msg: msg} do
    convo = Conversation.new

    {:ok, convo} = Conversation.say(convo, relationship.trader, msg)

    require IEx
    IEx.pry()

  end

end
