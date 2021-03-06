defmodule CodeWriter do
 def translate(commands, path) do
    {:ok, f} = File.open path, [:write]

    if !is_nil(f) do
      commands
      |> Enum.map(fn line -> write(line) end)
      |> Enum.map(fn asm -> IO.write(f, asm) end)

      File.close f

      {:ok}
    else 
      {:error, "File not found"}
    end  
  end

  #write A-instruction
  defp write({:a_command, address}) do
   binary = 
    address
    |> String.to_integer
    |> Integer.to_string(2)
    |> String.pad_leading(15, "0") 
   
   "0#{binary}\n" 
  end

  #write C-instruction
  defp write({:c_command, dest, comp, jmp}) do
    "111#{translate_comp(comp)}#{translate_dest(dest)}#{translate_jmp(jmp)}\n"
  end

  defp write(_line) do
  end


  defp translate_comp(input) do

    has_m = ~r/M/

    a = 
      case input =~ has_m  do
        true ->  "1"
        false -> "0"
      end

    line = String.replace(input, "M", "A") 

    comp = 
      case line do
        "0"    -> "101010"
        "1"    -> "111111"
        "-1"   -> "111010"
        "D"    -> "001100"
        "A"    -> "110000"
        "!D"   -> "001101"
        "!A"   -> "110001"
        "-D"   -> "001111"
        "-A"   -> "110011"
        "D+1"  -> "011111"
        "A+1"  -> "110111"
        "D-1"  -> "001110"
        "A-1"  -> "110010"
        "D+A"  -> "000010"
        "D-A"  -> "010011"
        "A-D"  -> "000111"
        "D&A"  -> "000000"
        "D|A"  -> "010101"
      end 

    "#{a}#{comp}"
  end

  defp translate_dest(line) do
    case line do
      nil    -> "000"
      "M"    -> "001"
      "D"    -> "010"
      "MD"   -> "011"
      "A"    -> "100"
      "AM"   -> "101"
      "AD"   -> "110"
      "AMD"  -> "111"
    end
  end

  defp translate_jmp(line) do
    case line do
      nil    -> "000"
      "JGT"  -> "001"
      "JEQ"  -> "010"
      "JGE"  -> "011"
      "JLT"  -> "100"
      "JNE"  -> "101"
      "JLE"  -> "110"
      "JMP"  -> "111"
    end
  end
end
