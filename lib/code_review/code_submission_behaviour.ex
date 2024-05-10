defmodule CodeReview.CodeSubmissionBehaviour do
  @moduledoc false

  @type submission_t :: %{
          author_id: String.t(),
          code_snippet: String.t(),
          language: String.t(),
          description: String.t() | nil
        }

  @doc """
  Funções para gerar o ID, utilizando base64
  """

  def create_id(length) do
    length
    |> random_bytes()
    |> Base.url_encode64(padding: false)
    |> take_first_chars(length)
  end

  defp random_bytes(n) do
    :crypto.strong_rand_bytes(n)
  end

  defp take_first_chars(string, n) do
    String.slice(string, 0, n)
  end

  @doc """
  Utilizamos o ETS para adicionar os mapas em uma lista. Para isso, criamos uma tabela ets com o nome :submitted_codes,
  com as opções set -> para colocar  uma chave para cada valor, sem chaves duplicadas, caso seja colocada a mesma chave duas vezes.
  protected, qualquer um pode ver mas somente pessoas autorizadas podem lidar com a tabela e o :name_table para que possamos invocar a tabela pelo nome dado a ela
  """

  def creating_table() do
    codes_table = :ets.new(:submitted_codes, [:set, :protected, :named_table])
  end

  @doc """
  Submete um novo snippet de código ao sistema. Antes de submeter é checado se o usuário manda todos os dados como strings, caso sim, geramos um ID para o autor da submissão
  e adicionamos esse ID no mapa. Por fim, criamos um ID para o código submetido, para que possamos colocar a submissão na lista e conseguir resgatar ela facilmente depois. As submissões
  são colocadas na lista como uma tupla, onde  o primeiro valor é a chave /ID e o segundo valor é o mapa com todas as informações, dessa forma: {:id, %{}}
  """

  @callback submit_code(submission_t) :: {:ok, Map.t()} | {:error, String.t()}
  def submit_code(submission_map) do
    with true <- submission_map[:snip] |> is_binary(),
         true <- submission_map[:language] |> is_binary(),
         true <- submission_map[:description] |> is_binary() do
      user_id = create_id(3)
      map_with_id = Map.put(submission_map, :author_id, user_id)
      submission_id = create_id(4)
      :ets.insert_new(:submitted_codes, {submission_id, map_with_id})
      :ok
    end
  end

  @doc """
  Atualiza um snippet de código existente.
  """
  @callback update_code(code_id :: String.t(), changes :: submission_t) ::
              {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Duas funções para mostrar as submissões, a primeira mostra todas as submissões dentro da lista, sendo assim uma lista que contém diferentes tuplas -> {:id, %map}
  . A segunda função resgata uma única submissão com base no ID, que ao fim retorna somente o mapa
  """
  @callback get_submissions :: list(submission_t)
  def get_submissions() do
    :ets.tab2list(:submitted_codes)
  end

  def get_submission(id) do
    :ets.lookup(:submitted_codes, id)
    |> get_submission_map
  end

  def get_submission_map(submitted_code_list) do
    [hd | tl] = submitted_code_list
    {id, sub_map} = hd
    sub_map
  end
end
