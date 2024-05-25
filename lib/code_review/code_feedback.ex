defmodule CodeReview.CodeFeedback do
  @moduledoc """
  Módulo responsável pela gestão de feedback e comentários em snippets de código.
  """
  # Gracias zoey e GPT
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

  def get_comment(id) do
    CodeReview.CodeFeedbackGenserver.show_comment(id)
      |> get_comment_map
  end

  def get_thread_id(parent_id) do
    CodeReview.CodeFeedbackGenserver.show_comment(parent_id)
      |> get_comment_map
      |> extract_thread_id
  end

  def get_comment_map(comment) do
    [hd | _tl] = comment
    {_id, sub_map} = hd
    sub_map
  end

  def extract_thread_id(comment) do
    comment[:thread_id]
  end

  def add_comment(comment_t) do
    with true <- comment_t[:text] |> is_binary(),
      true <- comment_t[:commenter_id] |> is_binary() do
      with true <- comment_t[:parent_id] |> is_binary() do
        comment_id = create_id(5)
        map_with_id = Map.put(comment_t, :id, comment_id)
        parent = comment_t[:parent_id]
        map_with_thread = 
          Map.put(map_with_id, :thread_id, get_thread_id(parent))
        CodeReview.CodeFeedbackGenserver.add_comment(comment_id, map_with_thread)
        {:ok, map_with_thread}
      else
        false -> 
        comment_id = create_id(5)
        map_with_id = Map.put(comment_t, :id, comment_id)
        map_with_thread = Map.put(map_with_id, :thread_id, create_id(5))
        CodeReview.CodeFeedbackGenserver.add_comment(comment_id, map_with_thread)
        {:ok, map_with_thread}
      end
    else
      false -> {:error, "Erro na criação de comentário!"}
    end
  end

  def update_comment(id, comment_t) do
    o_comment = get_comment(id)
    with true <- comment_t[:text] |> is_binary() do
      # map_with_id = Map.put(comment_t, :id, o_comment[:id])
      map_with_thread = Map.put(comment_t, :thread_id, o_comment[:thread_id])
      map_with_parent = Map.put(map_with_thread, :parent_id, o_comment[:parent_id])
      CodeReview.CodeFeedbackGenserver.update_comment(id, map_with_parent)
      {:ok, map_with_parent}
    else
      false -> {:error, "Erro na criação de comentário!"}
    end
  end

  @behaviour CodeReview.CodeFeedbackBehaviour
end
