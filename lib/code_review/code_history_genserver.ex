defmodule CodeReview.CodeHistoryGenserver do
  use GenServer

  @moduledoc """
  GenServer para gerenciar votações de comentários.
  """

  def start_link do
    GenServer.start_link(__MODULE__, :comment_votes, name: __MODULE__)
  end

  def add_vote(comment_id, voter_id, vote_type) do
    GenServer.cast(__MODULE__, {:add_vote, {comment_id, voter_id, vote_type}})
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
  def handle_cast({:add_vote, {comment_id, voter_id, vote_type}}, table) do
    vote = %{comment_id: comment_id, voter_id: voter_id, vote_type: vote_type}

    case :ets.lookup(table, comment_id) do
      [] ->
        :ets.insert_new(table, {comment_id, [vote]})
      [{_comment_id, votes}] ->
        :ets.insert(table, {comment_id, votes ++ [vote]})
    end

    {:noreply, table}
  end
end