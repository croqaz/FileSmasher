defmodule FileSmasher.SevenZip.Helpers do
  @moduledoc """
  Helper module for parsing command line output.
  """

  @doc false
  def compress_args(options) do
    case options do
      # 7zip LZMA compression
      {:'7z'} -> ["-m0=lzma"]
      {:'7z', :min} ->   ~W/-m0=lzma -mx=1 -ms=off -mf=off/
      {:'7z', :fast} ->  ~W/-m0=lzma -mx=3/
      {:'7z', :max} ->   ~W/-m0=lzma2 -mx=7 -ms=on -mf=on/
      {:'7z', :ultra} -> ~W/-m0=lzma2 -mx=9 -ms=on -mf=on/
      # ZIP Deflate compression
      {:zip} -> ["-tzip"]
      {:zip, :min} ->   ~W/-tzip -mx=1 -mm=Deflate/
      {:zip, :fast} ->  ~W/-tzip -mx=3/
      {:zip, :max} ->   ~W/-tzip -mx=7 -mm=Deflate64/
      {:zip, :ultra} -> ~W/-tzip -mx=9 -mm=Deflate64/
    end
  end

  @doc false
  def match_common_output(match) do
    match = Map.update! match, "files", &(elem(Integer.parse(&1), 0))
    match = Map.update! match, "o_bytes", &(elem(Integer.parse(&1), 0))
    match = Map.update! match, "arch_bytes", &(elem(Integer.parse(&1), 0))
    Map.put match, "ratio", Float.round(match["arch_bytes"] / match["o_bytes"], 3)
  end

  @doc false
  def parse_list_output_zip(output) do
    match = Regex.named_captures(~r/
      ^Type[ ]=[ ](?<type>\S+).+
      ^Physical[ ]Size[ ]=[ ](?<arch_bytes>\d+).+
      ^\d{4}-\d{2}-\d{2}[ ]\d{2}:\d{2}:\d{2}\s+
      (?<o_bytes>\d+)\s+\d+\s+
      (?<files>\d+)[ ]files?
      /xms, output)
    match_common_output(match)
  end

  @doc false
  def parse_list_output_7z(output) do
    match = Regex.named_captures(~r/
      ^Method[ ]=[ ](?<method>\S+)$.+
      ^Solid[ ]=[ ](?<solid>[-+])$
      /xms, output)
    match = Map.update! match, "solid", &(&1 == "+")
    match_zip = parse_list_output_zip(output)
    Map.merge(match_zip, match)
  end

end
