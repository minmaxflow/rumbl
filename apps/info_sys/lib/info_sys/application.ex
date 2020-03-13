defmodule InfoSys.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # You’ll specify a single element containing a two-tuple having the module you want to start and the value that will be received on start_link by the GenServer. 
      # Alternatively, passing in only a module name uses a default value of []
      InfoSys.Cache,
      {Task.Supervisor, name: InfoSys.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InfoSys.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

# restart strategies 
#   :permant(default), :temparey :transient
# 方法1
# children = [
#   ​ 	  Supervisor.child_spec({InfoSys.Counter, 5}, ​restart:​ ​:permanent​)
#   ​ 	]
# 方法2
#  	​defmodule​ InfoSys.Counter ​do​
# ​ 	  ​use​ GenServer, ​restart:​ ​:permanent​
# ​ 	  ...
# ​ 	​end
# 方法3 
#  定义 child_spec(arg) 方法

# supervision strategies 
#   定义child termiate之后，整个supervison tree 的行为
# :one_for_one(默认), :one_for_all, :rest_for_one 

# Task
# 默认是link的，所以如果task崩溃，会导致 当前process terminate，这个是默认行为
#    task1 = Task.async(​fn​ -> access_some_api() ​end​)
# ​ 	task2 = Task.async(​fn​ -> access_another_api() ​end​)
# ​ 	Task.await(task1)
# ​ 	Task.await(task2)
#  如果不想，就使用 Task.Supervisor.async_nolink instead of the typical Task.async
