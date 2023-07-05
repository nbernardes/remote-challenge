defmodule Remote.Utils.Error do
  @moduledoc """
  Module responsible for gathering all possible application errors.
  """
  def not_found, do: {:error, :not_found}
end
