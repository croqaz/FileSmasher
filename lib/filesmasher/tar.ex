defmodule FileSmasher.Tar do
  @moduledoc """
  A thin wrapper over the tar executable.
  """
  alias Porcelain.Result
  import FileSmasher.Tar.Helpers, only: :functions

  @spec info(String.t) :: map
  def info(archive) do
    # Execute tar list
    %Result{out: output, status: status} = Porcelain.shell "stat -s #{archive} && tar tfvv #{archive}"
    if status == 0, do: parse_list_output(output), else: %{error: "Cannot get info!"}
  end

  @spec compress(String.t, String.t, tuple) :: atom | map
  def compress(arch, path, method \\ {:gz}) do
    cmd = compress_args(method)
    # Execute tar create archive
    %Result{status: status} = Porcelain.shell "tar cv #{path} | #{cmd} > #{arch}"
    if status == 0, do: :ok, else: %{error: "Cannot tar compress!"}
  end

  @spec extract(String.t, String.t, boolean) :: atom | map
  def extract(arch, path \\ "", overwrite \\ false) do
    over = if overwrite, do: "", else: "k"
    path = if String.length(path) > 0, do: "-C #{path}", else: ""
    # Execute tar extract
    %Result{status: status} = Porcelain.shell "tar xvf#{over} #{arch} #{path}"
    if status <= 1, do: :ok, else: %{error: "Cannot tar extract!"}
  end

end
