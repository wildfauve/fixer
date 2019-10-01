defmodule Fixer.Message do

  alias __MODULE__

  alias Fixer.FieldReference

  @enforce_keys [:type, :msg, :msg_components]

  @field_separator "|"
  @value_separator "="
  @msg_type "MsgType"

  defstruct [:type, :msg, :msg_components]

  def new(fix_message) do
    with {:ok, msg_components}   <- split(fix_message),
         {:ok, msg_type}         <- to_type(msg_components)
    do
      {:ok, %Message{type: msg_type, msg_components: msg_components, msg: fix_message} }
    else
      {:error} -> {:error, "Invalid Message\n"}
    end
  end

  def find_by_field_name(message, name) do
    Enum.find(message.msg_components, fn [id, _value] -> id == name end)
  end

  defp split(msg) do
    with true <- String.match?(msg, ~r/\|/)
    do
      {:ok, String.split(msg, @field_separator)
            |> Enum.map(&(String.split(&1, @value_separator)))
            |> Enum.map(fn [id, value] -> [FieldReference.field_def(id), value] end) }
    else
      false -> {:error}
    end
  end

  # naive version
  defp to_type(components) do
    case Enum.find(components, fn [id, _value] -> id == @msg_type end) do
      [@msg_type, "8"] -> {:ok, :execution_report}
      [@msg_type, "A"] -> {:ok, :login}
      _                -> {:error}
    end
  end

end
