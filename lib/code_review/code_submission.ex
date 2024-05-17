defmodule CodeReview.CodeSubmission do
  @moduledoc """
  Módulo responsável pela submissão e manipulação de snippets de código.
  """

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


def submit_code(submission_map) do
  with true <- submission_map[:snip] |> is_binary(),
       true <- submission_map[:language] |> is_binary(),
       true <- submission_map[:description] |> is_binary() do
    user_id = create_id(3)
    map_with_id = Map.put(submission_map, :author_id, user_id)
    submission_id = create_id(4)
    CodeReview.CodeSubmissionGenserver.add({submission_id, map_with_id})
    #:ets.insert_new(:submitted_codes, {submission_id, map_with_id})
    #IO.puts("Submissão criada com o ID #{submission_id}")
  end
end

def get_submissions() do
  CodeReview.CodeSubmissionGenserver.show_table()
end

def get_submission(id) do
  :ets.lookup(:submitted_codes, id)
  |> get_submission_map
end

def get_submission_map(submitted_code_list) do
  [hd | tl] = submitted_code_list
  {id, sub_map} = hd
  sub_map
end



  @behaviour CodeReview.CodeSubmissionBehaviour
end
