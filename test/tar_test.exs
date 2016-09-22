defmodule FileSmasherTarTest do
  use ExUnit.Case, async: false
  alias FileSmasher.Tar
  defp path(), do: "test/documents"

  setup do
    on_exit fn ->
      arch_tgz = "test/documents.tgz"
      arch_tbz = "test/documents.tbz"
      arch_txz = "test/documents.txz"
      if File.regular?(arch_tgz) do
        File.rm(arch_tgz)
        IO.puts "Delete TGZ achive.."
      end
      if File.regular?(arch_tbz) do
        File.rm(arch_tbz)
        IO.puts "Delete TBZ achive.."
      end
      if File.regular?(arch_txz) do
        File.rm(arch_txz)
        IO.puts "Delete TXZ achive.."
      end
      :ok
    end
  end

  test "compress test min" do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing MIN #{type} =")
        arch = path <> ".t#{type}"
        :ok = Tar.compress(arch, path, {type, :min})
        nfo = Tar.info(arch) |> IO.inspect
        assert nfo.files == 3
        cond do
          nfo.type == "gzip" ->
            assert nfo.ratio == 0.986
          nfo.type == "bzip2" ->
            assert nfo.ratio == 0.988
          nfo.type == "xz" ->
            assert nfo.ratio == 0.989
        end
        :ok = Tar.extract(arch)
    end)
  end

  test "compress test normal" do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing normal #{type} =")
        arch = path <> ".t#{type}"
        :ok = Tar.compress(arch, path, {type})
        nfo = Tar.info(arch) |> IO.inspect
        assert nfo.files == 3
        cond do
          nfo.type == "gzip" ->
            assert nfo.ratio == 0.984
          nfo.type == "bzip2" ->
            assert nfo.ratio == 0.984
          nfo.type == "xz" ->
            assert nfo.ratio == 0.986
        end
        :ok = Tar.extract(arch)
    end)
  end

  test "compress test max" do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing MAX #{type} =")
        arch = path <> ".t#{type}"
        :ok = Tar.compress(arch, path, {type, :max})
        nfo = Tar.info(arch) |> IO.inspect
        assert nfo.files == 3
        cond do
          nfo.type == "gzip" ->
            assert nfo.ratio == 0.984
          nfo.type == "bzip2" ->
            assert nfo.ratio == 0.983
          nfo.type == "xz" ->
            assert nfo.ratio == 0.986
        end
        :ok = Tar.extract(arch)
    end)
  end

end
