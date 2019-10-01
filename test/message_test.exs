defmodule MessageTest do
  use ExUnit.Case
  doctest Fixer

  alias Fixer.Message

  setup do
    msgs = %{ exec_rpt: "8=FIX.4.2|9=97|35=8|6=10|11=12345|14=100|17=1|20=0|31=10|32=100|37=1|38=100|39=2|54=1|55=BHP|100=AX|150=2|151=0|10=038",
              login:    "8=FIX.4.2|9=97|35=A|49=fnz.co.nz|56=jarden.co.nz|50=sub:1|553=hamster|554=password"}
    %{msgs: msgs}
  end

  test "determines the type of a message", %{msgs: msgs} do
    {:ok, msg} = Message.new(Map.get(msgs, :exec_rpt))

    assert msg.type == :execution_report
  end

  test "tokenises the message fields", %{msgs: msgs} do
    {:ok, msg} = Message.new(Map.get(msgs, :exec_rpt))

    assert Enum.map(msg.msg_components, fn [k,_v] -> k end) == ["BeginString", "BodyLength", "MsgType", "AvgPx", "ClOrdID", "CumQty", "ExecID",
                                                                "ExecTransType", "LastPx", "LastShares", "OrderID", "OrderQty", "OrdStatus",
                                                                "Side", "Symbol", "ExDestination", "ExecType", "LeavesQty", "CheckSum"]
  end

  test "fails when the message type cant be found" do
    assert {:error} = Message.new("a=1")
  end

end
