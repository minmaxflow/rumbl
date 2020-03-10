# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.Repo

alias Rumbl.Accounts
alias Rumbl.Accounts.User

users = [
  %{name: "Jose", username: "josevalim", password: "temppass"},
  %{name: "Bruce", username: "redcapids", password: "tempass"},
  %{name: "Chris", username: "chrismccord", password: "tempass"}
]

for user <- users do
  {:ok, %User{}} = Accounts.register_user(user)
end
