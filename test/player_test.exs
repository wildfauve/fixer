defmodule PlayerTest do
  use ExUnit.Case
  
  alias Fixer.Player

  test "player has a role" do
    {:ok, player} = Player.new("player1", :trader)

    assert player.role == :trader
  end

end
