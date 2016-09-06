defmodule FileSmasherSevenTest do
  use ExUnit.Case, async: false
  alias FileSmasher.SevenZip

  setup_all do
    arch_7z = System.cwd <> "/test/documents.7z"
    arch_zip = System.cwd <> "/test/documents.zip"
    if File.regular?(arch_7z) do
      File.rm(arch_7z)
      IO.puts "Deleted old 7z achive.."
    end
    if File.regular?(arch_zip) do
      File.rm(arch_zip)
      IO.puts "Deleted old zip achive.."
    end
    :ok
  end

  def assert_size(curr, nfo) do
    assert curr["files"] == nfo["files"]
    assert curr["orig_size"] == nfo["orig_size"]
    assert curr["arch_size"] == nfo["arch_size"]
  end

  test "compress folder with 7z min" do
    path = System.cwd <> "/test/documents"
    arch = path <> ".7z"
    o1 = SevenZip.compress(arch, path, {:'7z', :min}) |> IO.inspect
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "7z"
    assert nfo["solid"] == false
    assert_size(o1, nfo)
    :ok = SevenZip.extract(arch, path)
  end

  test "compress folder with 7z ultra" do
    path = System.cwd <> "/test/documents"
    arch = path <> ".7z"
    o1 = SevenZip.compress(arch, path, {:'7z', :ultra}) |> IO.inspect
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "7z"
    assert nfo["solid"] == true
    assert_size(o1, nfo)
    :ok = SevenZip.extract(arch, path)
  end

  test "compress folder with zip min" do
    path = System.cwd <> "/test/documents"
    arch = path <> ".zip"
    o1 = SevenZip.compress(arch, path, {:zip, :min}) |> IO.inspect
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "zip"
    assert_size(o1, nfo)
    :ok = SevenZip.extract(arch, path)
  end

  test "compress folder with zip ultra" do
    path = System.cwd <> "/test/documents"
    arch = path <> ".zip"
    o1 = SevenZip.compress(arch, path, {:zip, :ultra}) |> IO.inspect
    nfo = SevenZip.info(arch) |> IO.inspect
    assert nfo["files"] == 3
    assert nfo["type"] == "zip"
    assert_size(o1, nfo)
    :ok = SevenZip.extract(arch, path)
  end

  test "listing invalid archive should fail" do
    arch = System.cwd <> "/test/documents.xyz"
    %{error: e} = SevenZip.info(arch)
    assert is_binary(e) == true
  end

  test "extract invalid archive should fail" do
    path = System.cwd <> "/test/documents"
    arch = path <> ".xyz"
    %{error: e} = SevenZip.extract(arch, path)
    assert is_binary(e) == true
  end

  test "extract in invalid path should fail" do
    path = "/"
    arch = System.cwd <> "/test/documents.zip"
    %{error: e} = SevenZip.extract(arch, path)
    assert is_binary(e) == true
  end

end
