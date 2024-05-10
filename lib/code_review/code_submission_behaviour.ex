defmodule CodeReview.CodeSubmissionBehaviour do
  @moduledoc false

  @type submission_t :: %{
          author_id: String.t(),
          code_snippet: String.t(),
          language: String.t(),
          description: String.t() | nil
        }


  @doc """
  Funções para gerar o ID
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
  Função para adicionar mapas na lista
  """

  def creating_table() do
    codes_table = :ets.new(:submitted_codes,[:set, :protected, :named_table])
  end


  @doc """
  Submete um novo snippet de código ao sistema.
  """


  @callback submit_code(submission_t) :: {:ok, Map.t()} | {:error, String.t()}
  def submit_code(submission_map) do
    with true <- submission_map[:snip] |> is_binary(),
         true <- submission_map[:language] |> is_binary(),
         true <- submission_map[:description] |> is_binary()   do
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
  Lista todas as submissões
  """
  @callback get_submissions :: list(submission_t)
  def get_submissions() do
    :ets.tab2list(:submitted_codes)
  end

  def get_submission(id) do
    :ets.lookup(:submitted_codes,id)
    |> get_submission_map
  end

  def get_submission_map(submitted_code_list) do
    [hd | tl]  = submitted_code_list
    {id, sub_map} = hd
    sub_map
  end
end
