defmodule CodeReview.CodeHistoryBehaviour do
  @moduledoc false

  @type vote_t :: %{comment_id: String.t(), voter_id: String.t(), vote_type: :upvote | :downvote}

  @doc """
  Registra um voto em um comentário.
  """
  @callback vote_on_comment(vote_t) :: {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Obtém o histórico de revisões de um snippet de código.
  """
  @callback get_revision_history(code_id :: String.t()) :: list(vote_t)
end
