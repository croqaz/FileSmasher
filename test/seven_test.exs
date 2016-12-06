defmodule FileSmasherSevenTest do
  use ExUnit.Case
  alias FileSmasher.SevenZip
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
      [:'7z', :zip], fn type ->
        IO.puts("\n= Compressing #{level} #{type} =")
        initial_files = ls_r(path)
        ext = type |> to_string
        arch = path <> "." <> ext
        :ok = SevenZip.compress(arch, path, {type, level})
        nfo = SevenZip.info(arch) |> IO.inspect
        assert nfo["files"] == 3
        assert nfo["type"] == ext
        assert nfo["ratio"] > 0.98 && nfo["ratio"] < 1
        if type == :'7z' && level != :min, do: assert nfo["solid"] == true
        File.rm_rf(path)
        :ok = SevenZip.extract(arch, ".")
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

  test "listing invalid archive should fail", %{temp_path: path} do
    arch = path <> "/documents.xyz"
    %{error: e} = SevenZip.info(arch)
    assert is_binary(e) == true
  end

  test "extract invalid archive should fail", %{temp_path: path} do
    arch = path <> ".xyz"
    %{error: e} = SevenZip.extract(arch, path)
    assert is_binary(e) == true
  end

  # test "extract in invalid path should fail", %{temp_path: path} do
  #   arch = path <> ".zip"
  #   :ok = SevenZip.compress(arch, path, {:zip, :min})
  #   %{error: err} = SevenZip.extract(arch, "/x/y/z")
  #   assert is_binary(err) == true
  # end

end
