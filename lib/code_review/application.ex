defmodule CodeReview.Application do
  def start(_type, _args) do
    children = [
      CodeReview.CodeSubmissionGenserver,
      CodeReview.CodeHistoryGenserver,
      CodeReview.CodeFeedbackGenserver
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CR.Supervisor)
  end
end
