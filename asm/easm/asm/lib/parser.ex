defmodule Parser do

  def parse(stream) do
    analyze stream
  end

  defp analyze(stream) do
    commands =
      stream
      |> Enum.map(&String.strip/1)
      |> Enum.map(fn line -> token(line) end)
      |> Enum.map(fn line -> process(line) end) 
      |> Enum.filter(fn item -> !is_nil(item) end)
    
    symbols = 
      gather_symbols(commands, 0, %{}) 
      |> Map.merge(preset_symbols) 

    replace_symbols(commands, symbols, []) 
  end

  defp token(line) do
    [first | _rest] = String.split(line, " ")
    first
  end

  # skip empty lines
  defp process("") do
  end

  # skip comment lines
  defp process("//" <> _comment) do
  end

  # A command 
  defp process("@" <> rest) do
    line = String.split(rest, " ")
    
    symbol=
      case  Enum.count(line) do
      1 -> [first] = line
           first 
      true -> [first, _rest] = line
           first 
      end

    {:a_command, symbol}
  end

  # L command
  defp process("(" <> rest) do
     [_full_match, symbol] = Regex.run(~r/(.*)\)/, rest) 
    {:l_command, symbol}
  end

  # C command
  defp process(line) do
    has_dest = ~r/=/

    {rest, dest} = 
      case line =~ has_dest do
        true -> [h, t] = String.split(line, "=")
                {t, h}
        false -> {line, nil}
      end
    
    has_jump = ~r/;/

    {comp, jmp} = 
      case rest =~ has_jump do
        true -> [first, second] = String.split(line, ";") 
                {first, second} 
        false -> {rest, nil}
      end

    {:c_command, dest, comp, jmp} 
  end

  defp gather_symbols([], _count, symbols) do
    symbols
  end

  defp gather_symbols([{:l_command, symbol}|t], count, symbols) do
    gather_symbols(t, count, Map.put(symbols, symbol, count))
  end

  defp gather_symbols([_h|t], count, symbols) do
    gather_symbols(t, count + 1, symbols)
  end

  defp preset_symbols() do
    %{
       "SP"     => 0,
       "LCL"    => 1,
       "ARG"    => 2,
       "THIS"   => 3,
       "THAT"   => 4,
       "R0"     => 0,
       "R1"     => 1,
       "R2"     => 2,
       "R3"     => 3,
       "R4"     => 4,
       "R5"     => 5,
       "R6"     => 6,
       "R7"     => 7,
       "R8"     => 8,
       "R9"     => 9,
       "R10"     => 10,
       "R11"     => 11,
       "R12"     => 12,
       "R13"     => 13,
       "R14"     => 14,
       "R15"     => 15,
       "SCREEN"  => 16384,
       "KBD"     => 24576,
       "VARN"    => 0
     }
  end


  defp replace_symbols([], _symbols, result) do
    Enum.reverse(result)
  end

  defp replace_symbols([h|t], symbols, result) do
    {command, new_symbols} = replace_symbol(h, symbols) 
    replace_symbols(t, new_symbols, [command|result])
  end


  defp replace_symbol({:a_command, symbol}, symbols) do

    {address, new_symbols} =
      cond  do
       symbol =~ ~r/^\d.*$/ -> 
       {String.to_integer(symbol), symbols}  

       Map.has_key?(symbols, symbol) -> 
       {Map.get(symbols, symbol), symbols}

       true       -> 
        offset = Map.get(symbols, "VARN") 
        var_address = 16 + offset

        new_symbols = 
        symbols
        |> Map.put(symbol, var_address)
        |> Map.put("VARN", (offset + 1))

        # IO.puts "symbol: #{symbol} address: #{var_address}  offset #{offset} VARN: #{Map.get(symbols, "VARN")}"

        { var_address, new_symbols}
      end

      {{:a_command, Integer.to_string(address)}, new_symbols}
  end

  defp replace_symbol(command, symbols) do
    {command, symbols}
  end

  defp write(data, path) do
    {:ok, file} = File.open path, [:write] 
    content = Kernel.inspect data
    IO.binwrite file, content 
    File.close file
  end
end
