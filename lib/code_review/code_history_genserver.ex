defmodule CodeReview.CodeHistoryGenserver do
  use GenServer

  @moduledoc """
  GenServer para gerenciar votações de comentários.
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, :comment_votes, name: __MODULE__)
  end

  def add_vote(vote_t) do
    GenServer.cast(__MODULE__, {:add_vote, vote_t})
  end

  def list_votes(comment_id) do
    GenServer.call(__MODULE__, {:list_votes, comment_id})
  end

  # -----------------

  @impl true
  def init(table_name) do
    table = :ets.new(table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:list_votes, comment_id}, _from, table) do
    votes = :ets.lookup(table, comment_id)
              |> Enum.flat_map(fn {_comment_id, votes} -> votes end)
    {:reply, votes, table}
  end

  @impl true
  def handle_cast({:add_vote, vote_t}, table) do

    case :ets.lookup(table, vote_t[:comment_id]) do
      [] ->
        :ets.insert_new(table, {vote_t[:comment_id], [vote_t]})
      [{_comment_id, votes}] ->
        :ets.insert(table, {vote_t[:comment_id], votes ++ [vote_t]})
    end

    {:noreply, table}
  end
end
