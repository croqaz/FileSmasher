defmodule FileSmasher.Tar do
  @moduledoc """
  A thin wrapper over the tar executable.
  """
  alias Porcelain.Result
  import FileSmasher.Tar.Helpers, only: :functions

  @spec info(String.t) :: map
  def info(archive) do
    # Execute tar list
    %Result{out: output, status: status} = Porcelain.shell ~s(tar tfvv "#{archive}")
    info = if status == 0, do: parse_list_output(output), else: %{error: "Cannot get info!"}
    arch_size = File.stat!(archive).size
    ratio = if info.orig_size > 0, do: Float.round(arch_size / info.orig_size, 3), else: 1
    Map.merge info, %{arch_size: arch_size, ratio: ratio}
  end

  @spec compress(String.t, String.t, tuple) :: atom | map
  def compress(arch, path, method \\ {:gz}) do
    cmd = compress_args(method)
    # Execute tar create archive
    dir = Path.dirname path
    pth = Path.basename path
    %Result{status: status} = Porcelain.shell ~s(tar cv -C "#{dir}" "#{pth}" | #{cmd} > "#{arch}")
    if status == 0, do: :ok, else: %{error: "Cannot tar compress!"}
  end

  @spec extract(String.t, String.t, boolean) :: atom | map
  def extract(arch, path \\ "", overwrite \\ false) do
    over = if overwrite, do: "", else: "k"
    path = if String.length(path) == 0 || path == ".", do: "", else: ~s(-C "#{path}")
    # Execute tar extract
    %Result{status: status} = Porcelain.shell ~s(tar xvf#{over} "#{arch}" "#{path}")
    if status <= 1, do: :ok, else: %{error: "Cannot tar extract!"}
  end

end
