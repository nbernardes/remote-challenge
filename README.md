# Remote Challenge

## Deployment

[Fly.io](https://remote-challenge.fly.dev/)

(If the requests take a bit of time, don't worry, the machine is in a sleep state, and will go back up once the first request is sent. After that, all requests are in the normal Phoenix speed we are used to 💪)

I've deployed the app to facilitate on the review process when there is no coding review involved. If you want to review the logic itself, you can use the link above, take a look on the endpoints below and play a bit! The database is filled with some dummy data.

⚠️ **Note:** Do not abuse on the **POST `/invite-users`** since it will make the same job for all active salary users without worrying if the user has already been notified or not.

#

## Project Setup and Startup

To setup the project:

- Make sure you have installed the correct `erlang`, `elixir` and `postgres` versions defined on `.tool_versions` file.
- Run `mix setup`

To start the Phoenix server locally:

- Run `bin/server`

#

## API Endpoints

I've created a Postman Collection that you can import to Postman and use the API.

- On the repo, go into `docs/api.postman_collection.json`
- Downlod the file, and import it on you Postman app.

**> GET `/api/users`**

- Returns a list of users paginated.
  - Accepts pagination parameters
    - `page` (default 1)
    - `page_size` (default 50, max 1000)
  - Accepts order by name
    - `order` (values `asc` or `desc`)
  - Accepts search by name
    - `search` (search for partial parts of a name)

**> POST `/api/invite-users`**

- Returns a job id and the current status of the job (most of the times will be `available` since the job has just been scheduled to run)

**> POST `/api/invite-users/status/{job-id}`**

- Returns information about the job corresponding to the given `job-id`
- Fails if the `job-id` is not found

To ease the ability to see completed jobs, I've disabled the `Oban Pruner` so all the jobs that are created and finished accumulate on the table. One more reason to be cautious when using this endpoint a lot of times.

#

## Implementation details

- Due to the direct updates I'm making to the Oban.Job to store additional information about the job process, I wasn't able to test the job effectively. The worker continues running until completion, making it impossible to assert anything about its execution. Additionally, in the test environment, for unknown reasons, the job no longer exists at the end of the execution

- On the `/api/invite-users` endpoint, having it working like this allows for the client to have a clear feedback of what happened. If the process was sync, it would take a lot of time to have a response on the endpoint (and probably would timeout either way). The warning I've added from exausting the endpoint could be solved rate limiting the endpoint.

- Having worked with GraphQL for several years, I strongly believe that it would be the ideal choice for this project due to its clarity and numerous advantages. (Although I must admit, my opinion might be slightly biased 😂)
