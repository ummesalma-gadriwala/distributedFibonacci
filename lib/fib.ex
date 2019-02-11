defmodule Fib do

  def fib_calc(1), do: 1
  def fib_calc(2), do: 1
  def fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)

  def server(caller) do
    send(caller, {:ready, self()})
    receive do
      {:compute, n, client} -> 
        result = fib_calc(n)
        send(client, {:answer, n, result})
        server(caller) 
      {:shutdown} -> exit(:normal)
    end    
  end

end


# pid = spawn(Fib, :server, [self()])
# receive do
#   {:ok, message} -> IO.puts(message)
# end

# send(pid, {:compute, 4, self()})

# receive do
#   {:answer, n, result} -> IO.puts(result)
# end

# send(pid, {:shutdown})


defmodule Scheduler do
  def start(num_servers, job_list) do
    # spawn num_servers many instances of Fib
    spawnServer(num_servers)
    # call run
    run(num_servers, job_list, [])
  end

  def run(num_servers, job_list, result_list) do 
    receive do
      {:ready, server_pid} -> 
        nToSend = List.first(job_list)
        cond do 
          # Is job list empty?
          nToSend == nil -> 
            # Send shutdown message to server
            send(server_pid, {:shutdown})
            
            if (num_servers <= 1) do
              result_list
            else
              run(num_servers-1, job_list, result_list)
            end
          # Job list is not empty
          true -> 
            # Send message to server with n from the head of job_list
            job_list = List.delete(job_list, nToSend);
            send(server_pid, {:compute, nToSend, self()})
            run(num_servers, job_list, result_list)
        end
      {:answer, n, result} ->
        # Add result to the head of result_list
        result_list = List.insert_at(result_list, 0, result)
        run(num_servers, job_list, result_list)
    end
  end

  defp spawnServer(1) do
   spawn(Fib, :server, [self()])
  end
  defp spawnServer(num_servers) do
    spawn(Fib, :server, [self()])
    spawnServer(num_servers - 1)
  end
  
end


# Scheduler.start(3,[1,2,3,4,5])


defmodule BetterFib do

  def fib_calc(n) do
     map = List.duplicate(0, n+1);
     map = List.replace_at(map, 1, 1);
     map = List.replace_at(map, 2, 1);
     helper(map)
  end

  defp helper([head | []]) do
    head
  end
  defp helper([head | tail]) do
    offByTwo = List.first(tail)
    new = head + offByTwo
    tail = List.replace_at(tail, 1, new);
    helper(tail)
  end

end


# BetterFib.fib_calc(4)
# BetterFib.fib_calc(10)