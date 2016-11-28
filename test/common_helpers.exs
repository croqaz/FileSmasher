defmodule FileSmasherHelpers do

  @cwd_path File.cwd!

  @spec ls_r(charlist) :: list(charlist)
  def ls_r(path) do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        path
        |> File.ls!
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat
      true -> []
    end
  end

  def create_temp_files do
    temp_path = Temp.mkdir! "file-smasher"
    # IO.puts "Created: #{temp_path}"
    File.cp_r! Path.expand("test/documents/", @cwd_path), temp_path
    File.cd! Path.dirname(temp_path)
    temp_path
  end

end
