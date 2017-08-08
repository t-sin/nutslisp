defmodule Mark.Lisp do
  @moduledoc """
  Lisp implementation to implement Mark the squirrel.
  """

  def whitespace?(ch) do
    ch == ?  or ch == ?\n or ch == ?\t
  end

  @doc """
  Read charlist to the point of f satisfied.
  f = fn ch -> <boolean> end
  """
  defp read_to(f, chlis, acc \\ []) do
    case chlis do
      [] -> {nil, nil, chlis}
      [ch | rest] -> if f.(ch) == true do
        {acc, ch, rest}
      else
        read_to(f, rest, acc ++ [ch])
      end
    end
  end

  defp skip_whitespace(chlis, acc \\ []) do
    {_, ch, rest} = read_to(whitespace?, chlis)
    [ch | rest]
  end

  def read_paren(chlis) do
    case read_to(?(, chlis) do
      {nil, _} -> read_paren(chlis)
    end
  end

  @doc """
  Read expression as string.
  """
  def read(str) do
    chlis = to_charlist(str)
    chlis = skip_whitespace(chlis)
    [ch | rest] = chlis

    cond do
      ch == ?( ->
        :list
      true ->
        :otherwise
    end
  end

  @doc """
  Evaluate expression.
  """
  def eval(exp) do
  end

  @doc """
  Print evaluation result.
  """
  def print(exp) do
  end
end
