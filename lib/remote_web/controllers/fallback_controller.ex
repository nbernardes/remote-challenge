defmodule RemoteWeb.FallbackController do
  use RemoteWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: RemoteWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RemoteWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
