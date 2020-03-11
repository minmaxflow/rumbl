defmodule RumblWeb.PageControllerTest do
  use RumblWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Rumbl"
  end
end

# The async: true flag allows the tests in this module to run concurrently with tests defined in other modules. 
# However, tests in the same module are always executed sequentially, in random order to avoid implicit dependencies between tests.
