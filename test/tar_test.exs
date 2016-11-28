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

  @spec template(atom, charlist) :: any
  def template(level, path) do
    Enum.map(
      [:gz, :bz, :xz], fn type ->
        IO.puts("\n= Compressing #{level} #{type} =")
        initial_files = ls_r(path)
        arch = path <> ".t#{type}"
        :ok = Tar.compress(arch, path, {type, level})
        nfo = Tar.info(arch) |> IO.inspect
        assert nfo.files == 3
        assert nfo.ratio > 0.98 && nfo.ratio < 1
        File.rm_rf(path)
        :ok = Tar.extract(arch)
        assert initial_files == ls_r(path)
    end)
  end

  test "compress test min", %{temp_path: path} do
    template(:min, path)
  end

  test "compress test default", %{temp_path: path} do
    template(:default, path)
  end

  test "compress test max", %{temp_path: path} do
    template(:max, path)
  end

end
