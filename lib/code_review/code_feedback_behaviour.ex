defmodule CodeReview.CodeFeedbackBehaviour do
  @moduledoc false

  @type comment_t :: %{
          code_id: String.t(),
          commenter_id: String.t(),
          text: String.t(),
          parent_id: String.t() | nil
        }

  @doc """
  Adiciona um comentário a um snippet de código.
  """
  @callback add_comment(comment_t) :: {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Atualiza um comentário existente.
  """
  @callback update_comment(comment_id :: String.t(), changes :: comment_t) ::
              {:ok, Map.t()} | {:error, String.t()}
end
