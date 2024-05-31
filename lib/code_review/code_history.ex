defmodule CodeReview.CodeHistory do
  @behaviour CodeReview.CodeHistoryBehaviour

  alias CodeReview.{CodeHistoryBehaviour, CodeHistoryGenserver, CodeFeedbackBehaviour}

  @impl CodeHistoryBehaviour
  def vote(%{comment_id: comment_id, voter_id: voter_id, vote_type: vote_type}) do
    case validate_vote_type(vote_type) do
      :ok ->
        case CodeFeedbackBehaviour.get_comment(comment_id) do
          {:ok, _comment} ->
            vote = %{comment_id: comment_id, voter_id: voter_id, vote_type: vote_type}
            save_vote(vote)
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

  defp save_vote(vote) do
    CodeHistoryGenserver.add_vote(vote.comment_id, vote.voter_id, vote.vote_type)
  end

  defp list_votes(comment_id) do
    CodeHistoryGenserver.list_votes(comment_id)
  end
end
