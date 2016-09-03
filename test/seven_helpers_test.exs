defmodule FileSmasherSevenHelpersTest do
  use ExUnit.Case
  alias FileSmasher.SevenZip

  test "parse info 7z file + folder" do
    o = "Listing archive: test/documents.7z\n\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 7550944\nHeaders Size = 307\nMethod = LZMA2:23\nSolid = +\nBlocks = 1\n\n   Date      Time    Attr         Size   Compressed  Name\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:39:40 D....            0            0  test/documents\n2016-08-31 16:36:29 ....A      6010879      7550637  test/documents/Comfort_Fit - Sorry.mp3\n2016-08-31 16:25:23 ....A       518076               test/documents/Elixir-Lang.pdf\n2016-08-31 16:39:13 ....A      1129054               test/documents/photo-1443641998979-d59cfcf800c4.jpeg\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:39:40            7658009      7550637  3 files, 1 folders\n"
    m = SevenZip.parse_list_output o
    assert m["type"] == "7z"
    assert m["solid"] == true
    assert m["files"] == 3
  end

  test "parse info 7z 1 file" do
    o = "Listing archive: test/documents.7z\n\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 511010\nHeaders Size = 170\nMethod = LZMA2:19\nSolid = -\nBlocks = 1\n\n   Date      Time    Attr         Size   Compressed  Name\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:25:23 ....A       518076       510840  test/documents/Elixir-Lang.pdf\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:25:23             518076       510840  1 files\n"
    m = SevenZip.parse_list_output o
    assert m["type"] == "7z"
    assert m["solid"] == false
    assert m["files"] == 1
  end

  test "parse info 7z 2 files" do
    o = "Listing archive: test/documents.7z\n\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 1625933\nHeaders Size = 255\nMethod = LZMA2:1536k\nSolid = -\nBlocks = 2\n\n   Date      Time    Attr         Size   Compressed  Name\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:25:23 ....A       518076       510840  test/documents/Elixir-Lang.pdf\n2016-08-31 16:39:13 ....A      1129054      1114838  test/documents/photo-1443641998979-d59cfcf800c4.jpeg\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:39:13            1647130      1625678  2 files\n"
    m = SevenZip.parse_list_output o
    assert m["type"] == "7z"
    assert m["solid"] == false
    assert m["files"] == 2
  end

end
