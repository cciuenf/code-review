defmodule CodeReview.CodeSubmissionBehaviour do
  @moduledoc false

  @type submission_t :: %{
          author_id: String.t(),
          code_snippet: String.t(),
          language: String.t(),
          description: String.t() | nil
        }

  @doc """
  Submete um novo snippet de código ao sistema.
  """
  @callback submit_code(submission_t) :: {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Atualiza um snippet de código existente.
  """
  @callback update_code(code_id :: String.t(), changes :: submission_t) ::
              {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Lista todas as submissões
  """
  @callback get_submissions :: list(submission_t)
end
