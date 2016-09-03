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

  test "compress folder with 7z min" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:'7z', :min}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.7z") |> IO.inspect
    assert o2["files"] == 3
    assert o2["type"] == "7z"
    assert o2["solid"] == false
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

  test "compress folder with 7z ultra" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:'7z', :ultra}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.7z") |> IO.inspect
    assert o2["files"] == 3
    assert o2["type"] == "7z"
    assert o2["solid"] == true
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

  test "compress folder with zip min" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:zip, :min}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.zip") |> IO.inspect
    assert o2["type"] == "zip"
    assert o2["files"] == 3
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

  test "compress folder with zip ultra" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:zip, :ultra}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.zip") |> IO.inspect
    assert o2["type"] == "zip"
    assert o2["files"] == 3
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

end
