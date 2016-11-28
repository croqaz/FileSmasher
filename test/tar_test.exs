defmodule FileSmasherTarTest do
  use ExUnit.Case, async: false
  alias FileSmasher.Tar
  import FileSmasherHelpers

  setup do
    temp_path = create_temp_files
    on_exit fn ->
      # IO.puts "Cleanup: #{temp_path}"
      File.rm_rf(temp_path)
    end
    {:ok, [temp_path: temp_path]}
  end

  test "compress test min", %{temp_path: path} do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing MIN #{type} =")
        initial_files = ls_r(path)
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
        File.rm_rf(path)
        :ok = Tar.extract(arch)
        assert initial_files == ls_r(path)
    end)
  end

  test "compress test normal", %{temp_path: path} do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing normal #{type} =")
        initial_files = ls_r(path)
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
        File.rm_rf(path)
        :ok = Tar.extract(arch)
        assert initial_files == ls_r(path)
    end)
  end

  test "compress test max", %{temp_path: path} do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing MAX #{type} =")
        initial_files = ls_r(path)
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
        File.rm_rf(path)
        :ok = Tar.extract(arch)
        assert initial_files == ls_r(path)
    end)
  end

end
