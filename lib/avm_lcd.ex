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
    Process.sleep(1000)
    IO.inspect("YMN test")

    # # --- 修正箇所: XIAO ESP32S3 のピン番号 (SDA=5, SCL=6) ---
    i2c = I2C.open([{:scl, 6}, {:sda, 5}, {:clock_speed_hz, 1_000_000}])

    IO.inspect("OK")
    # # 初期化
    init_lcd(i2c)

    init_rgb(i2c)
    IO.inspect("OK2-1")

    set_rgb(i2c, 100, 100, 200)

    # 文字を表示
    print(i2c, "YMN Test")
  end

  # --- 以下は変更なし ---
  def init_lcd(i2c) do
    # 1. Function Set (0x38: DL=1: 8bit, N=1: 2R, F=0: 5x7)
    #    - AIP31068Lの Function Set コマンドは 0b0011NFXX, N=1, F=0 の場合 0b001110XX = 0x38
    send_cmd(i2c, 0x38)
    # Wait for more than 40us (1msで十分)
    Process.sleep(1)

    # 2. Display ON/OFF Control (0x0C: D=1, C=0, B=0)
    send_cmd(i2c, 0x0C)
    # Wait for more than 39us (1msで十分)
    Process.sleep(1)

    # 3. Display Clear (0x01)
    #send_cmd(i2c, 0x01)
    # Wait for more than 1.53ms (2msで十分)
    #Process.sleep(2)

    # 4. Entry Mode Set (0x06: I/D=1, S=0)
    #send_cmd(i2c, 0x06)
    # 念のため
    #Process.sleep(1)
  end

  # 代替案: パターンマッチングで1バイトずつ取り出す
  def print(i2c, <<char, rest::binary>>) do
    send_data(i2c, char)
    print(i2c, rest)
  end

  def print(_i2c, "") do
    :ok
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
