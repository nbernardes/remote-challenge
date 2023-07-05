defmodule Remote.Utils.Result do
  @moduledoc """
  Module responsibe for normalizing results from functions
  """
  alias Remote.Utils.Error

  def normalize(nil), do: Error.not_found()
  def normalize(resource), do: {:ok, resource}
end
