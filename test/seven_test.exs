defmodule FileSmasherSevenTest do
  use ExUnit.Case, async: false
  alias FileSmasher.SevenZip

  test "compress folder with 7z min" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:'7z', :min}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.7z") |> IO.inspect
    assert o2["type"] == "7z"
    assert o2["solid"] == false
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

  test "compress folder with 7z ultra" do
    path = System.cwd <> "/test/documents"
    o1 = SevenZip.compress(path, {:'7z', :ultra}) |> IO.inspect
    o2 = SevenZip.info(System.cwd <> "/test/documents.7z") |> IO.inspect
    assert o2["type"] == "7z"
    assert o2["solid"] == true
    assert o1["o_bytes"] == o2["o_bytes"]
    assert o1["arch_bytes"] == o2["arch_bytes"]
  end

end
