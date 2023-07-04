defmodule RemoteWeb.AccountsControllerTest do
  use RemoteWeb.ConnCase, async: true

  describe "index" do
    test "lists all users and respective salaries", %{conn: conn} do
      %{user: user} = salary = insert(:salary)

      # We'll add a second salary that's inactive just to ensure the salary
      # that is being shown on the endpoint is the active/most recent
      insert(:salary, user: user, inactive_at: DateTime.utc_now())

      conn = get(conn, ~p"/api/users")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => user.id,
                 "name" => user.name,
                 "salary" => %{
                   "amount" => %{
                     "currency" => Atom.to_string(salary.amount.currency),
                     "formatted" => Money.to_string(salary.amount),
                     "value" => salary.amount.amount
                   },
                   "id" => salary.id,
                   "inactive_at" => nil,
                   "inserted_at" => DateTime.to_iso8601(salary.inserted_at),
                   "updated_at" => DateTime.to_iso8601(salary.updated_at)
                 },
                 "inserted_at" => DateTime.to_iso8601(user.inserted_at),
                 "updated_at" => DateTime.to_iso8601(user.updated_at)
               }
             ]
    end

    test "accepts pagination", %{conn: conn} do
      insert_list(2, :user)

      conn = get(conn, ~p"/api/users", %{"page" => 1, "page_size" => 1})

      response = json_response(conn, 200)

      assert response["page_number"] == 1
      assert response["page_size"] == 1
      assert response["total_entries"] == 2
      assert response["total_pages"] == 2
    end

    test "accepts sorting and ordering", %{conn: conn} do
      user = insert(:user, name: "Ma'am Jane Doe")
      insert(:user, name: "Sir John Doe")

      conn =
        get(conn, ~p"/api/users", %{
          "page" => 1,
          "page_size" => 1,
          "search" => "doe",
          "order" => "asc"
        })

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "id" => user.id,
                   "name" => user.name,
                   "salary" => nil,
                   "inserted_at" => DateTime.to_iso8601(user.inserted_at),
                   "updated_at" => DateTime.to_iso8601(user.updated_at)
                 }
               ],
               "page_number" => 1,
               "page_size" => 1,
               "total_entries" => 2,
               "total_pages" => 2
             }
    end
  end
end
