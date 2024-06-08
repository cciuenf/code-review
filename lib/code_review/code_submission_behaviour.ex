defmodule CodeReview.CodeSubmissionBehaviour do
  @moduledoc """
  Funções para gerar o ID, utilizando base64

  Utilizamos o ETS para adicionar os mapas em uma lista. Para isso, criamos uma tabela ets com o nome :submitted_codes,
  com as opções set -> para colocar  uma chave para cada valor, sem chaves duplicadas, caso seja colocada a mesma chave duas vezes.
  protected, qualquer um pode ver mas somente pessoas autorizadas podem lidar com a tabela e o :name_table para que possamos invocar a tabela pelo nome dado a ela

  Submete um novo snippet de código ao sistema. Antes de submeter é checado se o usuário manda todos os dados como strings, caso sim, geramos um ID para o autor da submissão
  e adicionamos esse ID no mapa. Por fim, criamos um ID para o código submetido, para que possamos colocar a submissão na lista e conseguir resgatar ela facilmente depois. As submissões
  são colocadas na lista como uma tupla, onde  o primeiro valor é a chave /ID e o segundo valor é o mapa com todas as informações, dessa forma: {:id, %{}}

  Atualiza um snippet de código existente.

  Duas funções para mostrar as submissões, a primeira mostra todas as submissões dentro da lista, sendo assim uma lista que contém diferentes tuplas -> {:id, %map}
  .A segunda função resgata uma única submissão com base no ID, que ao fim retorna somente o mapa

  """

  @type submission_t :: %{
          author_id: String.t(),
          code_snippet: String.t(),
          language: String.t(),
          description: String.t() | nil
        }

  @callback submit_code(submission_t) :: {:ok, submission_t()} | {:error, String.t()}

  @callback update_code(code_id :: String.t(), changes :: submission_t) ::
              {:ok, submission_t()} | {:error, String.t()}

  @callback get_submissions :: list(submission_t)
end
