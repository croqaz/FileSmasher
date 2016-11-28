defmodule FileSmasher.SevenZip.Helpers do
  @moduledoc """
  Helper module for parsing command line output.
  """

  @doc false
  def fix_common_match(match) do
    match = Map.update! match, "files", &(elem(Integer.parse(&1), 0))
    match = Map.update! match, "orig_size", &(elem(Integer.parse(&1), 0))
    match = Map.update! match, "arch_size", &(elem(Integer.parse(&1), 0))
    if match["orig_size"] > 0 do
      Map.put match, "ratio", Float.round(match["arch_size"] / match["orig_size"], 3)
    else
      Map.put match, "ratio", 0
    end
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

  @doc false
  def parse_list_output_zip(output) do
    match = Regex.named_captures(~r/
      ^Type[ ]=[ ](?<type>\S+).+
      ^Physical[ ]Size[ ]=[ ](?<arch_size>\d+).+
      ^\d{4}-\d{2}-\d{2}[ ]\d{2}:\d{2}:\d{2}\s+
      (?<orig_size>\d+)\s+\d+\s+
      (?<files>\d+)[ ]files?
      /xms, output)
    fix_common_match(match)
  end

  @doc false
  def parse_list_output(output) do
    if String.contains?(output, "Type = 7z\n") do
      parse_list_output_7z(output)
    else
      parse_list_output_zip(output)
    end
  end

  @doc false
  def compress_args(options) do
    case options do
      # 7zip LZMA compression
      {:'7z'} -> "-m0=lzma"
      {:'7z', :default} -> "-m0=lzma"
      {:'7z', :min} ->   "-m0=lzma -mx=1 -ms=off -mf=off"
      {:'7z', :fast} ->  "-m0=lzma -mx=3"
      {:'7z', :max} ->   "-m0=lzma2 -mx=7 -ms=on -mf=on"
      {:'7z', :ultra} -> "-m0=lzma2 -mx=9 -ms=on -mf=on"
      # ZIP Deflate compression
      {:zip} -> "-tzip"
      {:zip, :default} -> "-tzip"
      {:zip, :min} ->   "-tzip -mx=1 -mm=Deflate"
      {:zip, :fast} ->  "-tzip -mx=3"
      {:zip, :max} ->   "-tzip -mx=7 -mm=Deflate64"
      {:zip, :ultra} -> "-tzip -mx=9 -mm=Deflate64"
    end
  end

end
