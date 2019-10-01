defmodule Fixer.Player do

  alias __MODULE__

  @enforce_keys [:role, :handle]

  defstruct [:role, :handle, :host, :seq_number]

  def new(handle, role, host \\ "") do
    {:ok, %Player{handle: handle, role: role, host: host, seq_number: 1}}
  end

end
