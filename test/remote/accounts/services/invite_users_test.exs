defmodule Remote.Accounts.Services.InviteUsersTest do
  use Remote.DataCase, async: true
  use Oban.Testing, repo: Remote.Repo

  alias Remote.Accounts.Jobs
  alias Remote.Accounts.Services.InviteUsers

  describe "call" do
    test "enqueues a InviteUsers job" do
      {:ok, _} = InviteUsers.call()

      assert_enqueued worker: Jobs.InviteUsers
    end
  end
end
