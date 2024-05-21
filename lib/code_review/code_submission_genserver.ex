defmodule CodeReview.CodeSubmissionGenserver do
  use GenServer

  @moduledoc """
  Este módulo foi implementado para criar e gerenciar a tabela :ets que será responsável por guardar as submissões de código.

  Temos as funções do cliente:
    add -> adicionar submissão a tabela com base no ID e na propria submissao
    update -> atualiza submissao com base no ID e na "nova submissão"
    show-table -> mostra toda a tabela
    show_submission -> mostra submissão específica com base no ID

  Funções do servidor/callback
    start_link & init -> start_link é a função de inicialização do genserver, no segundo parametro dela
      passamos o estado inicial que é o que chega no callback init. Passamos o atom :submitted_codes que
      será recebido na init como table_name. Na init criamos a tabela ets usando o table_name
    handle_call -> foram implementados dois callbacks de call, um para mostrar toda a tabela e outro para
      mostrar somente uma submissão de código específica da tabela.
    handle_cast -> foram implementados tabém dois callbacks de cast, o de adição de submissão e o de update
       de uma determinada submissão.
  """

  def start_link(_) do
    # o segundo parametro do start_link é o que chega para o init
    GenServer.start_link(__MODULE__, :submitted_codes, name: __MODULE__)
  end

  def add(submission_id, submission_map) do
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
    [h | _t] = :ets.lookup(table, id)
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
