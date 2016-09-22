
# FileSmasher

A thin wrapper over Linux & Mac's `tar` and Igor Pavlov's `7-zip`.

This is alpha grade software, use at your own risk.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `filesmasher` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:filesmasher, "~> 0.1.0"}]
    end
    ```

  2. Ensure `filesmasher` is started before your application:

    ```elixir
    def application do
      [applications: [:filesmasher]]
    end
    ```
