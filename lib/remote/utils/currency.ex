defmodule Remote.Utils.Currency do
  @moduledoc """
  This module simulates some currencies to be used on salaries.
  """

  @spec supported_currencies() :: [atom]
  def supported_currencies do
    ~w(
      USD
      EUR
      JPY
      GBP
      AUD
      CAD
      CHF
      CNY
      SEK
      NZD
      MXN
      SGD
      HKD
      NOK
      KRW
      TRY
      RUB
      INR
      BRL
      ZAR
    )a
  end
end
