defmodule CodeReview.CodeSubmissionGenserver do
  use GenServer

  def start_link(table) do
    GenServer.start_link(__ MODULE__, :ets.new(:submitted_codes, [:set, :protected, :named_table]))
  end

  def add(submission_map) do
    GenServer.cast(__MODULE__, {:add, submission_map})
  end

  def update(old_map_id, changes) do
    GenServer.call(__MODULE__, {:update, old_map_id, changes})
  end

  def show_table() do
    GenServer.call(__MODULE__, :show)
  end

  def show_submission(submission_map) do
    GenServer.call(__MODULE__, {:show, submission_map})
  end

# -----------------

@impl true
def init(table) do
    {:ok, table}
end

@impl true
def handle_call({:show}, _from, table) do
  {:reply, :ets.tab2list(table)}
end

def handle_call({:show, submission_map}, _from, table) do
  {:reply, :ets.tab2list(table)}
end

def handle_cast({:add, submission_map}, table) do
  {:noreply, :ets.insert_new(table, submission_map)}
end

end
