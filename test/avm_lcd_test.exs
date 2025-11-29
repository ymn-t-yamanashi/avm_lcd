defmodule AvmLcdTest do
  use ExUnit.Case
  doctest AvmLcd

  test "greets the world" do
    assert AvmLcd.hello() == :world
  end
end
