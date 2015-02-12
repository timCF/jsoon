defmodule JsoonTest do
  use ExUnit.Case

  test "decode 1xbet" do
    File.read!("1xbet_line") |> Jsoon.decode |> is_list
    assert true 
  end
end
