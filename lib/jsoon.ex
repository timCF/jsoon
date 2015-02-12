defmodule Jsoon do
  use Application

 defp reload_protocols do
    :code.delete(Access)
    :code.delete(Collectable)
    :code.delete(Enumerable)
    :code.delete(Inspect)
    :code.delete(List.Chars)
    :code.delete(Range.Iterator)
    :code.delete(String.Chars)
    :code.delete(HashUtils)
  end

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
    res = Supervisor.start_link(children, opts)
    reload_protocols
    res
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

  def decode(bin, opts \\ []) when is_binary(bin) do
    case :jsonx.decode(bin, [format: :proplist]) do
      tuple when is_tuple(tuple) -> raise "#{__MODULE__} : error #{inspect tuple} while decoding term #{bin}"
      res -> parse_decoded(res, opts)
    end
  end
  defp parse_decoded(klst = [{_k,_v}|_], opts) do
    Enum.reduce(klst, %{}, fn({k,v}, resmap) -> Map.put(resmap, make_key(k, opts), parse_decoded(v, opts)) end)
  end
  defp parse_decoded(lst, opts) when is_list(lst), do: Enum.map(lst, &(parse_decoded(&1, opts)) )
  defp parse_decoded(:null, _), do: nil
  defp parse_decoded(term, _), do: term

  defp make_key(k, opts) do
    case {opts[:keys_numbers], opts[:keys_atoms]} do
      {nil, nil} -> k
      {false, false} -> k
      {nil, true} -> Maybe.to_atom(k)
      {false, true} -> Maybe.to_atom(k)
      {true, true} -> case Maybe.to_number(k) do
                        num when is_number(num) -> num
                        _ -> Maybe.to_atom(k)
                      end
      {true, nil} -> Maybe.to_number(k)
      {true, false} -> Maybe.to_number(k)
    end
  end

end
