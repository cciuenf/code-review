use crate::api;
use anyhow::Result;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct CodeSubmission {
    author_id: String,
    code_snippet: String,
    language: String,
    description: Option<String>,
}

impl CodeSubmission {
    pub async fn get_submission(code_id: String) -> Result<Self> {
        api::get::<CodeSubmission>(format!("/submissions/{}", code_id), None).await
    }

    pub async fn submit_code(
        author_id: String,
        code_snippet: String,
        language: String,
        description: Option<String>,
    ) -> Result<Self> {
        let submission = CodeSubmission {
            author_id,
            code_snippet,
            language,
            description,
        };

        api::post::<CodeSubmission>("/submissions", None, submission).await
    }
}
