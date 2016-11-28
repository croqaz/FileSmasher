defmodule FileSmasher.Tar do
  @moduledoc """
  A thin wrapper over the tar executable.
  """
  alias Porcelain.Result
  import FileSmasher.Tar.Helpers, only: :functions

  @spec info(String.t) :: map
  def info(archive) do
    # Execute tar list
    %Result{out: output, status: status} = Porcelain.shell ~s(file "#{archive}" ; tar tfv "#{archive}")
    if status == 0 do
      {ver, 0} = System.cmd "tar", ["--version"]
      cond do
        String.starts_with?(ver, "bsdtar") -> parse_list_output(:bsd, archive, output)
        String.contains?(ver, "(GNU tar)") -> parse_list_output(:gnu, archive, output)
      end
    else
      %{error: "Cannot get info!"}
    end
  end

  @spec compress(String.t, String.t, tuple) :: atom | map
  def compress(arch, path, method \\ {:gz}) do
    cmd = compress_args method
    dir = Path.dirname path
    pth = Path.basename path
    # Execute tar create archive
    %Result{status: status} = Porcelain.shell ~s(tar cv -C "#{dir}" "#{pth}" | #{cmd} > "#{arch}")
    if status == 0, do: :ok, else: %{error: "Cannot tar compress!"}
  end

  @spec extract(String.t, String.t, boolean) :: atom | map
  def extract(arch, path \\ "", overwrite \\ false) do
    over = if overwrite, do: "", else: "k"
    path = if String.length(path) == 0 || path == ".", do: "", else: ~s(-C "#{path}")
    # Execute tar extract
    %Result{status: status} = Porcelain.shell ~s(tar xvf#{over} "#{arch}" #{path})
    if status <= 1, do: :ok, else: %{error: "Cannot tar extract!"}
  end

end
