defmodule Asm do
  def main(args) do
    [file | _rest] = 
    args
    |> parse_args

    status = 
        file
        |> open_stream
        |> Parser.parse
        |> CodeWriter.translate("output.hack") 

    IO.inspect status
  end

  defp parse_args(args) do
    {_, arguments, _} =
    args
    |> OptionParser.parse(switches: [])

    arguments
  end

   defp open_stream(path) do
    try do
       File.stream!(path, [:utf8])
    rescue
      _  -> {:error, "File not found"} 
    end
  end

end
