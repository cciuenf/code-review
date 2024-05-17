defmodule CodeReview.CodeSubmissionGenserver do
  use GenServer


  def start_link(_) do
    #
    GenServer.start_link(__MODULE__, :submitted_codes, name: __MODULE__)

  end

  def add({submission_id, submission_map}) do
    GenServer.cast(__MODULE__, {:add, {submission_id, submission_map}})
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
def init(table_name) do
  table = :ets.new(table_name, [:set, :protected, :named_table])
    {:ok, table}
end

@impl true
def handle_call(:show, _from, table) do
  #:reply, o que vai fazer, novo estado
  {:reply, :ets.tab2list(table), table}
end

def handle_call({:show, id}, _from, table) do
  {:reply, :ets.lookup(table, id), table}
end

def handle_cast({:add, {submission_id, submission_map}}, table) do
  #as implementações de cast são colocadas fora da tupla
  :ets.insert_new(table, {submission_id, submission_map})
  #:noreply, novo estado
  {:noreply,table}
end

end
