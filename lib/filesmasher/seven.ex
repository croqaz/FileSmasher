defmodule FileSmasher.SevenZip do
  @moduledoc """
  A thin wrapper over the p7zip executable.
  """
  import FileSmasher.SevenZip.Helpers, only: :functions

  @doc false
  def parse_list_output(output) do
    if String.contains?(output, "Type = 7z\n") do
      parse_list_output_7z(output)
    else
      parse_list_output_zip(output)
    end
  end

  @doc """
  Get info about an existing archive.
  Supported formats: 7z, zip, gzip, bz2.
  """
  def info(archive) do
    arch = Path.expand(archive)
    # Execute 7z list
    { output, _ } = System.cmd "7z", ["l", arch]
    parse_list_output(output)
  end

  @doc false
  def parse_add_output(output) do
    match = Regex.named_captures(~r/
      ^Scanning[ ]the[ ]drive:\n.*
      (?<files>\d+)[ ]files?,\s
      (?<o_bytes>\d+)[ ]bytes[ ]\((?<o_size>.+?)\)$.+
      ^Archive[ ]size:[ ](?<arch_bytes>\d+)[ ]bytes[ ]\((?<arch_size>.+)\)$
      /xms, output)
    fix_common_match(match)
  end

  @doc """
  Compress a file, or folder.

  ##Methods:

  * {:'7z'} - normal 7Z, the default option
  * {:'7z', :min} - 7Z minimal compression (strength 1/9)
  * {:'7z', :fast} - 7Z fast compression (strength 3/9)
  * {:'7z', :max} - 7Z strong compression (strength 7/9, using LZMA2)
  * {:'7z', :ultra} - 7Z maximum possible compression (strength 9/9, using LZMA2)
  * {:zip} - normal ZIP compression
  * {:zip, :min} - ZIP minimal compression (strength 1/9)
  * {:zip, :fast} - ZIP fast compression (strength 3/9)
  * {:zip, :max} - ZIP strong compression (strength 7/9, using Deflate64)
  * {:zip, :ultra} - ZIP maximum possible compression (strength 9/9, using Deflate64)
  """
  @spec compress(String.t, String.t, tuple, list) :: map
  def compress(arch, path, method \\ {:'7z'}, args \\ []) do
    arch = Path.expand(arch)
    path = Path.expand(path)
    IO.puts(~s(Compress "#{path}" into "#{arch}".))
    # Execute 7z add
    { output, _ } = System.cmd("7z", ["a"] ++ compress_args(method) ++ args ++ [arch, path])
    parse_add_output(output)
  end

  @doc false
  def parse_extract_output(output) do
    match = Regex.named_captures(~r/
      ^Type\s=\s(?<type>\S+).+
      ^Size:\s+(?<o_bytes>\d+)$.+
      ^Compressed:\s+(?<arch_bytes>\d+)$
      /xms, output)
    match = case String.match?(output, ~r/Files: \d/) do
      true -> Map.put(match, "files", Regex.run(~r/^Files: (\d+)$/m, output) |> Enum.at(1))
      false -> Map.put(match, "files", "1")
    end
    match = case String.match?(output, ~r/Method = /) do
      true -> Map.put(match, "method", Regex.run(~r/^Method = (\S+)$/m, output) |> Enum.at(1))
      false -> match
    end
    fix_common_match(match)
  end

  @doc """
  Extract archive into a path.

  ##Overwrite existing files: true, or false.
  """
  @spec extract(String.t, String.t, boolean) :: map
  def extract(arch, path, overwrite \\ false) do
    arch = Path.expand(arch)
    path = "-o" <> Path.expand(path)
    args = if overwrite, do: ["-y"], else: ["-aos"]
    IO.puts(~s(Extracting "#{arch}".))
    # Execute 7z extract
    { output, _ } = System.cmd("7z", ["e"] ++ args ++ [arch, path])
    parse_extract_output(output)
  end

end
