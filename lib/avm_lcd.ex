defmodule AvmLcd do
  @moduledoc """
  Documentation for `AvmLcd`.
  """

  # I2Cアドレス定義
  @lcd_addr 0x3E
  @rgb_addr 0x62

  # コマンド定義
  @lcd_cmd_mode 0x80
  @lcd_data_mode 0x40

  # バックライト用レジスタ
  @reg_red 0x04
  @reg_green 0x03
  @reg_blue 0x02
  @reg_mode1 0x00
  @reg_output 0x08

  def start do
    Process.sleep(3000)
    IO.inspect("YMN test")

    # # --- 修正箇所: XIAO ESP32S3 のピン番号 (SDA=5, SCL=6) ---
    # {_, _i2c} =
    i2c = I2C.open([{:scl, 6}, {:sda, 5}, {:clock_speed_hz, 1_000_000}])
    # # -----------------------------------------------------

    IO.inspect("OK")
    # # 初期化
    init_lcd(i2c)

    init_rgb(i2c)
    IO.inspect("OK2-1")

    loop(i2c, 100)

    # # 文字を表示
    # print(i2c, "Hello XIAO!")

    # # 2行目へ移動して表示する例（コマンド 0xC0 = 2行目先頭）
    # send_cmd(i2c, 0xC0)
    # print(i2c, "ExAtomVM Rocks")
  end

  def loop(i2c, 255), do: loop(i2c, 0)

  def loop(i2c, c) do
    #Process.sleep(100)
    IO.inspect(c)
    set_rgb(i2c, 255, 0, c)
    loop(i2c, c + 1)
  end

  # --- 以下は変更なし ---

  def init_lcd(i2c) do
    Process.sleep(50)
    send_cmd(i2c, 0x38)
    Process.sleep(5)
    send_cmd(i2c, 0x38)
    Process.sleep(1)
    send_cmd(i2c, 0x0C)
    send_cmd(i2c, 0x01)
    Process.sleep(5)
    send_cmd(i2c, 0x06)
  end

  def print(i2c, str) do
    String.to_charlist(str)
    |> Enum.each(fn char -> send_data(i2c, char) end)
  end

  @compile {:no_warn_undefined, [I2C]}
  defp send_cmd(i2c, cmd) do
    I2C.write_bytes(i2c, @lcd_addr, <<@lcd_cmd_mode, cmd>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  defp send_data(i2c, data) do
    I2C.write_bytes(i2c, @lcd_addr, <<@lcd_data_mode, data>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  def init_rgb(i2c) do
    I2C.write_bytes(i2c, @rgb_addr, <<@reg_mode1, 0x00>>)
    I2C.write_bytes(i2c, @rgb_addr, <<@reg_output, 0xAA>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  def set_rgb(i2c, r, g, b) do
    I2C.write_bytes(i2c, @rgb_addr, <<@reg_red, r>>)
    I2C.write_bytes(i2c, @rgb_addr, <<@reg_green, g>>)
    I2C.write_bytes(i2c, @rgb_addr, <<@reg_blue, b>>)
  end
end
