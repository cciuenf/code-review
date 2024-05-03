import Config

config :supabase_potion,
  supabase_url: System.get_env("SUPABASE_URL"),
  supabase_api_key: System.get_env("SUPABASE_KEY")

config :supabase_gotrue,
  authentication_client: CodeReview.Supabase.GoTrue,
  endpoint: nil,
  signed_in_path: "/api",
  not_authenticated_path: "/api/login"
