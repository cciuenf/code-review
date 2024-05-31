defmodule CodeReview.CodeHistory do
  @behaviour CodeReview.CodeHistoryBehaviour

  alias CodeReview.{CodeHistoryBehaviour, CodeHistoryGenserver, CodeFeedbackBehaviour}

  @impl CodeHistoryBehaviour
  def vote_on_comment(vote_t) do
    case validate_vote_type(vote_t[:vote_type]) do
      :ok ->
        case CodeFeedbackBehaviour.get_comment(vote_t[:comment_id]) do
          {:ok, _comment} ->
            save_vote(vote_t)
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_vote_type(:upvote), do: :ok
  defp validate_vote_type(:downvote), do: :ok
  defp validate_vote_type(_), do: {:error, "Invalid vote type"}

  def save_vote(vote_t) do
    CodeHistoryGenserver.add_vote(vote_t)
  end

  def get_revision_history(comment_id) do
    CodeHistoryGenserver.list_votes(comment_id)
  end
end
