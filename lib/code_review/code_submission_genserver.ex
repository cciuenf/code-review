defmodule CodeReview.CodeSubmissionGenserver do
  use GenServer

  def start_link(_) do
    # o segundo parametro do start_link é o que chega para o init
    GenServer.start_link(__MODULE__, :submitted_codes, name: __MODULE__)
  end

  def add({submission_id, submission_map}) do
    GenServer.cast(__MODULE__, {:add, {submission_id, submission_map}})
  end

  def update(map_id, changes) do
    GenServer.cast(__MODULE__, {:update, {map_id, changes}})
  end

  def show_table() do
    GenServer.call(__MODULE__, :show)
  end

  def show_submission(submission_id) do
    GenServer.call(__MODULE__, {:show, submission_id})
  end

  # -----------------

  @impl true
  def init(table_name) do
    table = :ets.new(table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call(:show, _from, table) do
    # :reply, o que vai fazer, novo estado
    {:reply, :ets.tab2list(table), table}
  end

  @impl true
  def handle_call({:show, id}, _from, table) do
    {:reply, :ets.lookup(table, id), table}
  end

  @impl true
  def handle_cast({:update, {id, changes}}, table) do
    [h | t] = :ets.lookup(table, id)
    {_id, map} = h
    {:ok, author_id} = Map.fetch(map, :author_id)
    changes_with_id = Map.put(changes, :author_id, author_id)
    :ets.insert(table, {id, changes_with_id})
    {:noreply, table}
  end

  @impl true
  def handle_cast({:add, {submission_id, submission_map}}, table) do
    # as implementações de cast são colocadas fora da tupla
    :ets.insert_new(table, {submission_id, submission_map})
    # :noreply, novo estado
    {:noreply, table}
  end
end
