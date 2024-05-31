defmodule CodeReview.CodeHistory do
  @behaviour CodeReview.CodeHistoryBehaviour

  alias CodeReview.{CodeHistoryBehaviour, CodeFeedbackBehaviour}

  @initial_state %{}

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
    Agent.update(fn state -> save_vote_in_state(state, vote) end, @initial_state)
  end

  defp save_vote_in_state(state, vote) do
    comment_id = vote.comment_id
    case Map.get(state, comment_id) do
      nil ->
        updated_state = Map.put(state, comment_id, [vote])
        {:ok, updated_state}
      votes ->
        updated_votes = votes ++ [vote]
        updated_state = Map.put(state, comment_id, updated_votes)
        {:ok, updated_state}
    end
  end

  defp list_votes(comment_id) do
    Agent.get(__MODULE__, fn state -> Map.get(state, comment_id, []) end)
  end

end
