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

  test "compress folder with 7z min", %{temp_path: path} do
    initial_files = ls_r(path)
    arch = path <> ".7z"
    :ok = SevenZip.compress(arch, path, {:'7z', :min})
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "7z"
    assert nfo["solid"] == false
    File.rm_rf(path)
    :ok = SevenZip.extract(arch, ".")
    assert initial_files == ls_r(path)
  end

  test "compress folder with 7z ultra", %{temp_path: path} do
    initial_files = ls_r(path)
    arch = path <> ".7z"
    :ok = SevenZip.compress(arch, path, {:'7z', :ultra})
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "7z"
    assert nfo["solid"] == true
    File.rm_rf(path)
    :ok = SevenZip.extract(arch, ".")
    assert initial_files == ls_r(path)
  end

  test "compress folder with zip min", %{temp_path: path} do
    initial_files = ls_r(path)
    arch = path <> ".zip"
    :ok = SevenZip.compress(arch, path, {:zip, :min})
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "zip"
    File.rm_rf(path)
    :ok = SevenZip.extract(arch, ".")
    assert initial_files == ls_r(path)
  end

  test "compress folder with zip ultra", %{temp_path: path} do
    initial_files = ls_r(path)
    arch = path <> ".zip"
    :ok = SevenZip.compress(arch, path, {:zip, :ultra})
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "zip"
    File.rm_rf(path)
    :ok = SevenZip.extract(arch, ".")
    assert initial_files == ls_r(path)
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

  # test "extract in invalid path should fail" do
  #   path = "/"
  #   arch = System.cwd <> "/test/documents.zip"
  #   %{error: e} = SevenZip.extract(arch, path)
  #   assert is_binary(e) == true
  # end

end
