defmodule FileSmasher.SevenZip do
  @moduledoc """
  A thin wrapper over the p7zip executable.
  """
  alias Porcelain.Result
  import FileSmasher.SevenZip.Helpers, only: :functions

  @doc """
  Get info about an existing archive.
  Supported formats: 7z, zip, gzip, bz2.
  """
  @spec info(String.t) :: map
  def info(archive) do
    arch = Path.expand(archive)
    # Execute 7z list
    %Result{out: output, status: status} = Porcelain.shell "7z l #{arch}"
    if status === 0, do: parse_list_output(output), else: %{error: "Cannot get info!"}
  end

  @doc """
  Compress a file, or folder.

  ##Methods:

  * {:'7z'} - normal 7Z, the default option
  * {:'7z', :min} - 7Z minimal compression (strength 1/9)
  * {:'7z', :fast} - 7Z fast compression (strength 3/9)
  * {:'7z', :max} - 7Z strong compression (strength 7/9, using LZMA2)
  * {:'7z', :ultra} - 7Z maximum possible compression (strength 9/9, using LZMA2)
  * {:zip} - normal ZIP compression
  * {:zip, :min} - ZIP minimal compression (strength 1/9)
  * {:zip, :fast} - ZIP fast compression (strength 3/9)
  * {:zip, :max} - ZIP strong compression (strength 7/9, using Deflate64)
  * {:zip, :ultra} - ZIP maximum possible compression (strength 9/9, using Deflate64)
  """
  @spec compress(String.t, String.t, tuple, list) :: map
  def compress(arch, path, method \\ {:'7z'}, args \\ []) do
    arch = Path.expand(arch)
    path = Path.expand(path)
    IO.puts(~s(Compress "#{path}" into "#{arch}".))
    # Execute 7z add
    { output, _ } = System.cmd("7z", ["a"] ++ compress_args(method) ++ args ++ [arch, path])
    parse_add_output(output)
  end

  @doc """
  Extract archive into a path.

  ##Overwrite existing files: true, or false.
  """
  @spec extract(String.t, String.t, boolean) :: map
  def extract(arch, path, overwrite \\ false) do
    arch = Path.expand(arch)
    path = Path.expand(path)
    over = if overwrite, do: ["-y"], else: ["-aos"]
    IO.puts(~s(Extracting "#{arch}".))
    # Execute 7z extract
    %Result{status: status} = Porcelain.shell "7z e #{over} #{arch} -o#{path}"
    if status === 0, do: :ok, else: %{error: "Cannot extract!"}
  end

end
