defmodule Fixer.Act do

  alias __MODULE__

  defstruct [:speaker_role, :msg, :time]

  def new(speaker, msg), do: %Act{speaker_role: speaker.role, msg: msg, time: DateTime.utc_now()}

end
