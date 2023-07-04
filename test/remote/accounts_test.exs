defmodule Remote.AccountsTest do
  use Remote.DataCase, async: true

  alias Remote.Accounts

  describe "create_user/1" do
    test "creates user with name" do
      attrs = params_for(:user)

      {:ok, user} = Accounts.create_user(attrs)

      assert user.name == attrs.name
    end

    test "fails if name not given" do
      {:error, changeset} = Accounts.create_user(%{})

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "list_users_paginated/1" do
    test "returns a list of users paginated" do
      users = insert_list(2, :user)

      %{entries: entries} = page = Accounts.list_users_paginated()

      assert page.page_number == 1
      assert page.page_size == 50
      assert page.total_entries == 2
      assert page.total_pages == 1

      assert Enum.map(entries, & &1.id) |> Enum.sort() ==
               Enum.map(users, & &1.id) |> Enum.sort()
    end

    test "accepts before and after to change page" do
      users_ids = insert_list(3, :user) |> Enum.map(& &1.id)

      Enum.each(1..3, fn page_number ->
        pagination = [page: page_number, page_size: 1]

        %{entries: [user]} =
          page = Accounts.list_users_paginated(pagination: pagination)

        assert page.page_number == page_number
        assert page.page_size == 1
        assert page.total_entries == 3
        assert page.total_pages == 3
        assert user.id in users_ids
      end)
    end

    test "accepts searching by name" do
      user_a = insert(:user, name: "John Doe")
      user_b = insert(:user, name: "Jane Doe")

      # Let's first search for one user by a partial string that only he has
      %{entries: [user]} = Accounts.list_users_paginated(search: "  jO ")
      assert user.id == user_a.id

      # Then we search for the second user by a partial string that only he has
      %{entries: [user]} = Accounts.list_users_paginated(search: "JaN ")
      assert user.id == user_b.id

      # Then we search for both users by a partial string that both have
      %{entries: users, total_entries: 2} =
        Accounts.list_users_paginated(search: "DO")

      users_ids = Enum.map(users, & &1.id)
      assert user_a.id in users_ids
      assert user_b.id in users_ids
    end

    test "accepts ordering" do
      user_a = insert(:user, name: "Sir John Doe")
      user_b = insert(:user, name: "Ma'am Jane Doe")

      # By default, the users are order by ascending order if no search is given
      %{entries: [user]} =
        Accounts.list_users_paginated(pagination: [page_size: 1])

      assert user.id == user_b.id

      # We can change the order to be descending
      %{entries: [user]} =
        Accounts.list_users_paginated(
          pagination: [page_size: 1],
          order: Enum.random(["DESC", "desc", "  desc"])
        )

      assert user.id == user_a.id

      # If a search is given, order will be from the most similar descending
      %{entries: [user]} =
        Accounts.list_users_paginated(pagination: [page_size: 1], search: "doe")

      assert user.id == user_a.id

      # We can change the order to be ascending when given a search, which will
      # show the least similar entry first
      %{entries: [user]} =
        Accounts.list_users_paginated(
          pagination: [page_size: 1],
          search: "doe",
          order: Enum.random(["ASC", "asc", "  asc"])
        )

      assert user.id == user_b.id
    end
  end
end
