defmodule Mark.Lisp do
  @moduledoc """
  Lisp implementation to implement Mark the squirrel.
  """

  def whitespace?(ch) do
    ch == ?  or ch == ?\n or ch == ?\t
  end

  def digit?(ch) do
    ch == ?0 or ch == ?1 or ch == ?2 or ch == ?3 or ch == ?4 or ch == ?5 or
    ch == ?6 or ch == ?7 or ch == ?8 or ch == ?7 or ch == ?8 or ch == ?9
  end

  @doc """
  Read charlist to the point of f satisfied.
  f = fn ch -> <boolean> end
  """
  def read_to(f, chlis, acc \\ []) do
    case chlis do
      [] -> {nil, nil, chlis}
      [ch | rest] -> if f.(ch) == false do
        {acc, ch, rest}
      else
        read_to(f, rest, acc ++ [ch])
      end
    end
  end

  def read_integer(chlis, acc \\ []) do
    nil
  end

  def skip_whitespace(chlis, acc \\ []) do
    {_, ch, rest} = read_to(&whitespace?/1, chlis)
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
