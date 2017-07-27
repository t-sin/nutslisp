defmodule Mark.Lisp do
  @moduledoc """
  Lisp implementation to implement Mark the squirrel.
  """

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

  Read expression as string.
  """
  def read(str) do
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
