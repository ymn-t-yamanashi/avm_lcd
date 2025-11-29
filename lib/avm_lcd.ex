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
    # --- 修正箇所: XIAO ESP32S3 のピン番号 (SDA=5, SCL=6) ---
    {:ok, i2c} = I2C.open(sda: 5, scl: 6, speed_hz: 100_000)
    # -----------------------------------------------------

    # 初期化
    init_lcd(i2c)
    init_rgb(i2c)

    # 色をセット (青色にしてみましょう)
    set_rgb(i2c, 0, 0, 255)

    # 文字を表示
    print(i2c, "Hello XIAO!")

    # 2行目へ移動して表示する例（コマンド 0xC0 = 2行目先頭）
    send_cmd(i2c, 0xC0)
    print(i2c, "ExAtomVM Rocks")
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
    I2C.write(i2c, @lcd_addr, <<@lcd_cmd_mode, cmd>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  defp send_data(i2c, data) do
    I2C.write(i2c, @lcd_addr, <<@lcd_data_mode, data>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  def init_rgb(i2c) do
    I2C.write(i2c, @rgb_addr, <<@reg_mode1, 0x00>>)
    I2C.write(i2c, @rgb_addr, <<@reg_output, 0xAA>>)
  end

  @compile {:no_warn_undefined, [I2C]}
  def set_rgb(i2c, r, g, b) do
    I2C.write(i2c, @rgb_addr, <<@reg_red, r>>)
    I2C.write(i2c, @rgb_addr, <<@reg_green, g>>)
    I2C.write(i2c, @rgb_addr, <<@reg_blue, b>>)
  end
end
