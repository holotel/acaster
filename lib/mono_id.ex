defmodule MonoID do
  defdelegate gen(), to: SimpleMonoID
  defdelegate gen(type), to: SimpleMonoID

  def conv_raw(raw, :default) do
    <<a::32, b::16, c::16, d::16, e::48>> = raw

    Base.encode16(<<a::32>>) <>
      "-" <>
      Base.encode16(<<b::16>>) <>
      "-" <>
      Base.encode16(<<c::16>>) <>
      "-" <>
      Base.encode16(<<d::16>>) <>
      "-" <>
      Base.encode16(<<e::48>>)
  end
end

defmodule SimpleMonoID do
  @billion 1_000_000_000

  def gen(), do: gen(:default)

  def gen(:default), do: gen(:raw) |> MonoID.conv_raw(:default)

  def gen(:raw) do
    now = System.os_time(:nanosecond)
    {sec, subsec} = {div(now, 1 * @billion), rem(now, 1 * @billion)}
    <<sub_a::12, sub_b::12, sub_c::6>> = <<subsec::30>>
    clock = <<sec::36, sub_a::12, 0b0111::4, sub_b::12, 0b10::2, sub_c::6>>
    entropy = :crypto.strong_rand_bytes(7)
    clock <> entropy
  end
end

defmodule SeqMonoID do
  defstruct [:last, :seq]
  @billion 1_000_000_000

  def new(), do: %SeqMonoID{last: 0, seq: 0}

  def gen({now, seq}) do
    {sec, subsec} = {div(now, 1 * @billion), rem(now, 1 * @billion)}
    <<sub_a::12, sub_b::12, sub_c::6>> = <<subsec::30>>
    clock = <<sec::36, sub_a::12, 0b0111::4, sub_b::12, 0b10::2, sub_c::6, seq::8>>
    entropy = :crypto.strong_rand_bytes(6)
    clock <> entropy
  end

  def gen(%SeqMonoID{} = s) do
    gen(s, :default)
  end

  def gen(%SeqMonoID{} = s, :default) do
    {next, raw} = s |> gen(:raw)
    {next, raw |> MonoID.conv_raw(:default)}
  end

  def gen(%SeqMonoID{last: last, seq: seq}, :raw) do
    now = System.os_time(:nanosecond)

    case now > last do
      false -> {%SeqMonoID{last: now, seq: seq + 1}, gen({now, seq + 1})}
      true -> {%SeqMonoID{last: now, seq: 0}, gen({now, 0})}
    end
  end
end

defmodule SeqMonoIDAgent do
  def new(), do: Agent.start_link(fn -> SeqMonoID.new() end)
end
