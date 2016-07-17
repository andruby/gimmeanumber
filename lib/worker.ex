defmodule Gimmeanumber.Worker do
  use GenServer

  ## Client API

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def tweet(server, screen_name) do
    GenServer.call(server, {:tweet, screen_name})
  end

  ## Server Callbacks

  def init(:ok) do
    seed_prng
    worker = self()
    listener = spawn_link(fn -> Gimmeanumber.Listener.start_stream(worker) end)
    {:ok, listener}
  end

  def handle_call({:tweet, screen_name}, _from, pid) do
    {:reply, send_tweet(screen_name), pid}
  end

  ## Actual work

  defp send_tweet(screen_name) do
    number = :random.uniform(1001) -1
    message = "@#{screen_name} #{number}"
    IO.puts "Sending: #{message}"
    ExTwitter.update(message)
  end

  defp seed_prng do
    IO.puts "Seeding PRNG"
    << a :: size(32), b :: size(32), c :: size(32) >> = :crypto.rand_bytes(12)
    :random.seed(a, b, c)
  end
end
