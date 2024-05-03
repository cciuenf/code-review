defmodule CodeReview.DiscussionThreadsBehaviour do
  @moduledoc false

  @type thread_t :: %{code_id: String.t(), commenter_id: String.t(), text: String.t()}

  @doc """
  Inicia uma nova thread de discussão.
  """
  @callback start_thread(thread_t) :: {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Responde a uma thread existente.
  """
  @callback reply_to_thread(
              thread_id :: String.t(),
              commenter_id :: String.t(),
              text :: String.t()
            ) :: {:ok, Map.t()} | {:error, String.t()}
end
