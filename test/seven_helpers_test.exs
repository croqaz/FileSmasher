defmodule FileSmasherSevenHelpersTest do
  use ExUnit.Case
  alias FileSmasher.SevenZip

  test "parse info 7z files in folder" do
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
    assert m["o_bytes"] == 518076
    assert m["arch_bytes"] == 511010
  end

  test "parse info 7z 2 files" do
    o = "Listing archive: test/documents.7z\n\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 1625933\nHeaders Size = 255\nMethod = LZMA2:1536k\nSolid = -\nBlocks = 2\n\n   Date      Time    Attr         Size   Compressed  Name\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:25:23 ....A       518076       510840  test/documents/Elixir-Lang.pdf\n2016-08-31 16:39:13 ....A      1129054      1114838  test/documents/photo-1443641998979-d59cfcf800c4.jpeg\n------------------- ----- ------------ ------------  ------------------------\n2016-08-31 16:39:13            1647130      1625678  2 files\n"
    m = SevenZip.parse_list_output o
    assert m["type"] == "7z"
    assert m["solid"] == false
    assert m["files"] == 2
    assert m["o_bytes"] == 1647130
    assert m["arch_bytes"] == 1625933
  end

  test "parse info zip files in folder" do
    o = "Listing archive: test/documents.zip\n\n--\nPath = test/documents.zip\nType = zip\nPhysical Size = 7520721\n\n   Date      Time    Attr         Size   Compressed  Name\n------------------- ----- ------------ ------------  ------------------------\n2016-09-03 17:30:16 D....            0            0  documents\n2016-08-31 16:36:29 .....      6010879      5899804  documents/Comfort_Fit - Sorry.mp3\n2016-08-31 16:25:23 .....       518076       506271  documents/Elixir-Lang.pdf\n2016-08-31 16:39:13 .....      1129054      1113998  documents/photo-1.jpg\n------------------- ----- ------------ ------------  ------------------------\n2016-09-03 17:30:16            7658009      7520073  3 files, 1 folders\n"
    m = SevenZip.parse_list_output o
    assert m["type"] == "zip"
    assert m["files"] == 3
    assert m["o_bytes"] == 7658009
    assert m["arch_bytes"] == 7520721
  end

  # --- ADD ---

  test "parse adding a folder with 7z" do
    o = "Scanning the drive:\n2 folders, 3 files, 7658009 bytes (7479 KiB)\n\nCreating archive: test/documents.7z\n\nItems to compress: 5\n\n\nFiles read from disk: 3\nArchive size: 7550926 bytes (7374 KiB)\nEverything is Ok\n"
    m = SevenZip.parse_add_output o
    assert m["files"] == 3
    assert m["o_bytes"] == 7658009
    assert m["arch_bytes"] == 7550926
  end

  test "parse adding a file with 7z" do
    o = "Scanning the drive:\n1 file, 518076 bytes (506 KiB)\n\nCreating archive: test/documents.7z\n\nItems to compress: 1\n\n\nFiles read from disk: 1\nArchive size: 511010 bytes (500 KiB)\nEverything is Ok\n"
    m = SevenZip.parse_add_output o
    assert m["files"] == 1
    assert m["o_bytes"] == 518076
    assert m["arch_bytes"] == 511010
  end

  test "parse adding a folder with ZIP" do
    o = "Scanning the drive:\n2 folders, 3 files, 7658009 bytes (7479 KiB)\n\nCreating archive: test/documents.zip\n\nItems to compress: 5\n\n\nFiles read from disk: 3\nArchive size: 7546665 bytes (7370 KiB)\nEverything is Ok\n"
    m = SevenZip.parse_add_output o
    assert m["files"] == 3
    assert m["o_bytes"] == 7658009
    assert m["arch_bytes"] == 7546665
  end

  test "parse adding a file with ZIP" do
    o = "Scanning the drive:\n1 file, 518076 bytes (506 KiB)\n\nCreating archive: test/documents.zip\n\nItems to compress: 1\n\n\nFiles read from disk: 1\nArchive size: 508193 bytes (497 KiB)\nEverything is Ok\n"
    m = SevenZip.parse_add_output o
    assert m["files"] == 1
    assert m["o_bytes"] == 518076
    assert m["arch_bytes"] == 508193
  end

  # --- EXTRACT ---

  test "parse extracting a folder with ZIP" do
    o = "Scanning the drive for archives:\n1 file, 7546665 bytes (7370 KiB)\n\nExtracting archive: test/documents.zip\n--\nPath = test/documents.zip\nType = zip\nPhysical Size = 7546665\n\nEverything is Ok\n\nFolders: 2\nFiles: 3\nSize:       7658009\nCompressed: 7546665\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "zip"
    assert m["files"] == 3
    assert m["o_bytes"] == 7658009
    assert m["arch_bytes"] == 7546665
  end

  test "parse extracting 2 files with ZIP" do
    o = "Scanning the drive for archives:\n1 file, 1623632 bytes (1586 KiB)\n\nExtracting archive: test/documents.zip\n--\nPath = test/documents.zip\nType = zip\nPhysical Size = 1623632\n\nEverything is Ok\n\nFiles: 2\nSize:       1647130\nCompressed: 1623632\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "zip"
    assert m["files"] == 2
    assert m["o_bytes"] == 1647130
    assert m["arch_bytes"] == 1623632
  end

  test "parse extracting a file with ZIP" do
    o = "Scanning the drive for archives:\n1 file, 508193 bytes (497 KiB)\n\nExtracting archive: test/documents.zip\n--\nPath = test/documents.zip\nType = zip\nPhysical Size = 508193\n\nEverything is Ok\n\nSize:       518076\nCompressed: 508193\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "zip"
    assert m["files"] == 1
    assert m["o_bytes"] == 518076
    assert m["arch_bytes"] == 508193
  end

  test "parse extracting a folder with 7z" do
    o = "Scanning the drive for archives:\n1 file, 7550927 bytes (7374 KiB)\n\nExtracting archive: test/documents.7z\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 7550927\nHeaders Size = 290\nMethod = LZMA2:23\nSolid = +\nBlocks = 1\n\nEverything is Ok\n\nFolders: 2\nFiles: 3\nSize:       7658009\nCompressed: 7550927\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "7z"
    assert m["files"] == 3
    assert m["o_bytes"] == 7658009
    assert m["arch_bytes"] == 7550927
    assert String.split(m["method"], ":") |> hd == "LZMA2"
  end

  test "parse extracting 2 files with 7z" do
    o = "Scanning the drive for archives:\n1 file, 1625901 bytes (1588 KiB)\n\nExtracting archive: test/documents.7z\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 1625901\nHeaders Size = 223\nMethod = LZMA2:1536k\nSolid = -\nBlocks = 2\n\nEverything is Ok\n\nFiles: 2\nSize:       1647130\nCompressed: 1625901\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "7z"
    assert m["files"] == 2
    assert m["o_bytes"] == 1647130
    assert m["arch_bytes"] == 1625901
    assert String.split(m["method"], ":") |> hd == "LZMA2"
  end

  test "parse extracting a file with 7z" do
    o = "Scanning the drive for archives:\n1 file, 511010 bytes (500 KiB)\n\nExtracting archive: test/documents.7z\n--\nPath = test/documents.7z\nType = 7z\nPhysical Size = 511010\nHeaders Size = 170\nMethod = LZMA2:19\nSolid = -\nBlocks = 1\n\nEverything is Ok\n\nSize:       518076\nCompressed: 511010\n"
    m = SevenZip.parse_extract_output o
    assert m["type"] == "7z"
    assert m["files"] == 1
    assert m["o_bytes"] == 518076
    assert m["arch_bytes"] == 511010
    assert String.split(m["method"], ":") |> hd == "LZMA2"
  end

end
