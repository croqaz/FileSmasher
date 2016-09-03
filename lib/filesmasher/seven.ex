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
    match_common_output(match)
  end

  @doc """
  Compress a file, or folder.

  Options:

    - {:'7z'} - normal 7Z, the default option
    - {:zip} - normal ZIP compression
  """
  @spec compress(charlist, tuple) :: none
  def compress(path, options \\ {:'7z'}) do
    path = Path.expand(path)
    ext = elem(options, 0) |> to_string
    outz = Path.rootname(path) <> "." <> ext
    IO.puts(~s(Compress "#{path}" into "#{outz}".))
    # Execute 7z add
    { output, _ } = System.cmd("7z", ["a"] ++ compress_args(options) ++ [outz, path])
    parse_add_output(output)
  end

  @doc """
  Extract archive into a path.
  """
  # @spec extract(charlist) :: none
  # def extract(archive) do
  #   archive = Path.expand(archive)
  #   IO.puts(~s(Will extract "#{archive}".))
  #   nil
  # end

end
