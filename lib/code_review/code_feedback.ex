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

  # Dado um id procura no GenServer um comentario de mesmo id
  def get_comment(id) do
    CodeReview.CodeFeedbackGenserver.show_comment(id)
      |> get_comment_map
  end

  # Dado um parent_id retorna o thread_id do parent
  # Resgata no GenServer o parent comment
  # e atraves de pipes passa esse comentario para 
  # get_comment_map e para extract_thread_id
  def get_thread_id(parent_id) do
    CodeReview.CodeFeedbackGenserver.show_comment(parent_id)
      |> get_comment_map
      |> extract_thread_id
  end

  # dada uma tupla do ets que venha do CodeFeedbackGenserver retorna
  # o comentario que pertence a tupla
  def get_comment_map(comment) do
    [hd | _tl] = comment
    {_id, sub_map} = hd
    sub_map
  end

  # retorna o thread_id do comentario em questão
  def extract_thread_id(comment) do
    comment[:thread_id]
  end

  # Cria um comentario e adiciona ao GenServer
  # se o comentario nao possui, commenter_if, texto ou code_id
  # o comentario nao é criado e um erro é retornado
  def add_comment(comment_t) do
    with true <- comment_t[:text] |> is_binary(),
      true <- comment_t[:commenter_id] |> is_binary(),
      true <- comment_t[:code_id] |> is_binary() do

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

  # Permite que seja atualizado um comentario de ID especifico
  # é verificado se a edição possui texto e foi feita pelo mesmo autor 
  # do post original e esta editando o mesmo post ooriginal adiciona 
  # a mudança no GenServer caso contrário a edição falha e retorna um erro
  def update_comment(id, comment_t) do
    o_comment = get_comment(id)
    with true <- comment_t[:text] |> is_binary(),
         true <- comment_t[:code_id] == o_comment[:code_id],
         true <- comment_t[:commenter_id] == o_comment[:commenter_id] do
      map_with_thread = Map.put(comment_t, :thread_id, o_comment[:thread_id])
      map_with_parent = Map.put(map_with_thread, :parent_id, o_comment[:parent_id])
      CodeReview.CodeFeedbackGenserver.update_comment(id, map_with_parent)
      {:ok, map_with_parent}
    else
      false -> {:error, "Erro na edição de comentário!"}
    end
  end

  @behaviour CodeReview.CodeFeedbackBehaviour
end
