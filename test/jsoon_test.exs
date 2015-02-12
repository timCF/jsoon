defmodule JsoonTest do
  use ExUnit.Case
  require Logger

  test "decode 1xbet" do
  	bin = File.read!("1xbet_line")
    {time, _} = :timer.tc fn() -> Jsoon.decode(bin, [keys_atoms: true]) end
    Logger.debug "#{__MODULE__} : decoded 1xbet line by #{time/1000} ms"
    assert true 
  end
end
