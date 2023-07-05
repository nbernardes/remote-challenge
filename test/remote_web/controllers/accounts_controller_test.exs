defmodule RemoteWeb.AccountsControllerTest do
  use RemoteWeb.ConnCase, async: true

  alias Remote.Accounts.Services.InviteUsers

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

  describe "invite_users" do
    test "returns the ID of the job responsible for sending the emails async",
         %{conn: conn} do
      conn = post(conn, ~p"/api/invite-users")

      assert %{
               "id" => _job_id,
               "status" => "available"
             } = json_response(conn, 200)
    end
  end

  describe "invite_users_status" do
    test "returns information about the job of inviting users", %{conn: conn} do
      {:ok, job} = InviteUsers.call()

      conn = get(conn, ~p"/api/invite-users/status/#{job.args.id}")

      assert %{
               "id" => _job_id,
               "status" => "available",
               "additional_info" => %{
                 "page_number" => _,
                 "total_entries" => _,
                 "total_pages" => _
               }
             } = json_response(conn, 200)
    end

    test "fails when job isn't found", %{conn: conn} do
      conn = get(conn, ~p"/api/invite-users/status/1")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end
end
