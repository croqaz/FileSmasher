defmodule FileSmasher.Tar.Helpers do
  @moduledoc """
  Helper module for parsing "tar" command line output.
  """

  defp bsdtar_regex do
    ~r|^\S+[ ]+\d+[ ]+\S+[ ]+\S+[ ]+(\d+)[ ]+|
  end

  defp gnutar_regex do
    ~r|^\S+[ ]+\S+[ ]+(\d+)[ ]+|
  end

  @doc false
  def parse_list_output(tar, archive, output) do
    [h | t] = output |> String.trim |> String.split("\n")
    type = Regex.run(~r|: (\S+) compressed data|, h, capture: :all_but_first)
      |> hd |> String.downcase
    regex = if tar == :bsd, do: bsdtar_regex, else: gnutar_regex
    list =
      Enum.map(t, fn(txt) -> Regex.scan(regex, txt, capture: :all_but_first) |> hd |> hd end)
        |> Enum.map(&String.to_integer/1)
        |> Enum.filter(&(&1 > 0))
    files = list |> length
    orig_size = list |> Enum.sum
    arch_size = File.stat!(archive).size
    ratio = if orig_size > 0, do: Float.round(arch_size / orig_size, 3), else: 1
    %{
      type: type,
      files: files,
      orig_size: orig_size,
      arch_size: arch_size,
      ratio: ratio
    }
  end

  @doc false
  def compress_args(options) do
    case options do
      # GZIP compression
      {:gz} -> "gzip -6"
      {:gz, :default} -> "gzip -6"
      {:gz, :min} -> "gzip -1"
      {:gz, :max} -> "gzip -9"
      # BZ2 compression
      {:bz} -> "bzip2 -6"
      {:bz, :default} -> "bzip2 -6"
      {:bz, :min} -> "bzip2 -1"
      {:bz, :max} -> "bzip2 -9"
      # XZ compression
      {:xz} -> "xz -6"
      {:xz, :default} -> "xz -6"
      {:xz, :min} -> "xz -1"
      {:xz, :max} -> "xz -9 -e"
    end
  end

end
