defmodule Jsoon do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Jsoon.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jsoon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  #
  # encoding
  #

  def encode(term) do 
    case prepare_encode(term) |> :jsonx.encode do
      bin when is_binary(bin) -> bin
      error -> raise "#{__MODULE__} : error #{inspect error} while encoding term #{inspect term}"
    end
  end
  defp prepare_encode(map) when is_map(map) do 
    Map.to_list(map)
    |> Enum.map(fn({k,v}) -> {to_string(k), prepare_encode(v)} end)
  end
  defp prepare_encode(term), do: term

  #
  # decoding
  #

  def decode(bin) when is_binary(bin) do
    case :jsonx.decode(bin, [format: :proplist]) do
      tuple when is_tuple(tuple) -> raise "#{__MODULE__} : error #{inspect tuple} while decoding term #{bin}"
      res -> parse_decoded(res)
    end
  end
  defp parse_decoded(term) do
    term
    #
    # TODO
    #
  end

end
