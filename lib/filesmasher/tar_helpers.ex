defmodule FileSmasher.Tar.Helpers do
  @moduledoc """
  Helper module for parsing "tar" command line output.
  """

  @doc false
  def parse_list_output(o) do
    # Get archive size
    type = Regex.run(~r|POSIX \w+ format,  Compression: (\S+)$|, o, capture: :all_but_first) |> hd
    files = Regex.scan(~r|^\S+[ ]+\d+[ ]+\S+[ ]+\S+[ ]+[1-9]\d*[ ]+\S+|m, o) |> length
    sizes = Regex.scan(~r|^\S+[ ]+\d+[ ]+\S+[ ]+\S+[ ]+(\d+)[ ]+\S+|m, o, capture: :all_but_first)
    orig_size = Enum.map(sizes, fn(x) -> hd(x) |> Integer.parse |> elem(0) end) |> Enum.sum
    arch_size = Regex.run(~r|^.+ st_size=(\d+) |, o, capture: :all_but_first)
      |> hd |> Integer.parse |> elem(0)
    ratio = if orig_size > 0, do: Float.round(arch_size / orig_size, 3), else: 1
    %{
      type: type,
      files: files,
      arch_size: arch_size,
      orig_size: orig_size,
      ratio: ratio
    }
  end

  @doc false
  def compress_args(options) do
    case options do
      # GZIP compression
      {:gz} -> "gzip -6"
      {:gz, :min} -> "gzip -1"
      {:gz, :max} -> "gzip -9"
      # BZ2 compression
      {:bz} -> "bzip2 -6"
      {:bz, :min} -> "bzip2 -1"
      {:bz, :max} -> "bzip2 -9"
      # XZ compression
      {:xz} -> "xz -6"
      {:xz, :min} -> "xz -1"
      {:xz, :max} -> "xz -9 -e"
    end
  end

end
