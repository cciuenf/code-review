use anyhow::{Error, Result};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;
use token::AuthToken;

pub mod token;

const API_VERSION: &'static str = "v1";

fn get_api_key() -> String {
    std::env::var("API_KEY").expect("API_KEY must be set")
}

fn get_base_url() -> String {
    std::env::var("API_BASE_URL").unwrap_or("http://localhost:4000".to_string())
}

#[derive(Error, Debug)]
enum ApiError {
    #[error("Bad Request: {0}")]
    BadRequest(String),

    #[error("Not Found: {0}")]
    NotFound(String),

    #[error("Internal Server Error: {0}")]
    InternalServerError(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Forbidden: {0}")]
    Forbidden(String),

    #[error("Unknown Error: {0}")]
    Unknown(String),
}

type QueryParams = HashMap<String, String>;

#[derive(Serialize, Deserialize)]
pub struct LoginResponse {
    token: String,
    expires_in: u64,
}

fn maybe_handle_api_error(err: reqwest::Error) -> Error {
    match err.status() {
        Some(reqwest::StatusCode::BAD_REQUEST) => {
            return ApiError::BadRequest(err.to_string()).into();
        }
        Some(reqwest::StatusCode::NOT_FOUND) => {
            return ApiError::NotFound(err.to_string()).into();
        }
        Some(reqwest::StatusCode::INTERNAL_SERVER_ERROR) => {
            return ApiError::InternalServerError(err.to_string()).into();
        }
        Some(reqwest::StatusCode::UNAUTHORIZED) => {
            return ApiError::Unauthorized(err.to_string()).into();
        }
        Some(reqwest::StatusCode::FORBIDDEN) => {
            return ApiError::Forbidden(err.to_string()).into();
        }
        _ => {
            return ApiError::Unknown(err.to_string()).into();
        }
    }
}

pub async fn login() -> Result<LoginResponse> {
    let url = format!("{}/{}/login", get_base_url(), API_VERSION);
    let client = reqwest::Client::new();
    let response = client
        .post(&url)
        .query(&[("api_key", get_api_key())])
        .send()
        .await;

    match response {
        Ok(response) => return Ok(response.json::<LoginResponse>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}

pub async fn get<T>(path: String, query: Option<QueryParams>) -> Result<T>
where
    T: Serialize + DeserializeOwned,
{
    let url = format!("{}/{}/{}", get_base_url(), API_VERSION, path);
    let encoded = match query {
        None => Vec::new(),
        Some(params) => params.into_iter().collect::<Vec<(String, String)>>(),
    };
    let auth_token = AuthToken::initialize_and_authenticate(1).await;
    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .header("Authorization", auth_token.get_token().await.unwrap())
        .query(&encoded)
        .send()
        .await;

    match response {
        Ok(response) => return Ok(response.json::<T>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}

pub async fn post<T>(path: &str, query: Option<QueryParams>, body: T) -> Result<T>
where
    T: Serialize + DeserializeOwned,
{
    let url = format!("{}/{}/{}", get_base_url(), API_VERSION, path);
    let encoded = match query {
        None => Vec::new(),
        Some(params) => params.into_iter().collect::<Vec<(String, String)>>(),
    };
    let client = reqwest::Client::new();
    let response = client.post(&url).query(&encoded).json(&body).send().await;

    match response {
        Ok(response) => return Ok(response.json::<T>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}

pub async fn put<T>(path: String, query: Option<QueryParams>, body: T) -> Result<T>
where
    T: Serialize + DeserializeOwned,
{
    let url = format!("{}/{}/{}", get_base_url(), API_VERSION, path);
    let encoded = match query {
        None => Vec::new(),
        Some(params) => params.into_iter().collect::<Vec<(String, String)>>(),
    };
    let client = reqwest::Client::new();
    let response = client.put(&url).query(&encoded).json(&body).send().await;

    match response {
        Ok(response) => return Ok(response.json::<T>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}

pub async fn delete<T>(path: String, query: Option<QueryParams>) -> Result<T>
where
    T: Serialize + DeserializeOwned,
{
    let url = format!("{}/{}/{}", get_base_url(), API_VERSION, path);
    let encoded = match query {
        None => Vec::new(),
        Some(params) => params.into_iter().collect::<Vec<(String, String)>>(),
    };
    let client = reqwest::Client::new();
    let response = client.delete(&url).query(&encoded).send().await;

    match response {
        Ok(response) => return Ok(response.json::<T>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}

pub async fn patch<T>(path: String, query: Option<QueryParams>, body: T) -> Result<T>
where
    T: Serialize + DeserializeOwned,
{
    let url = format!("{}/{}/{}", get_base_url(), API_VERSION, path);
    let encoded = match query {
        None => Vec::new(),
        Some(params) => params.into_iter().collect::<Vec<(String, String)>>(),
    };
    let client = reqwest::Client::new();
    let response = client.patch(&url).query(&encoded).json(&body).send().await;

    match response {
        Ok(response) => return Ok(response.json::<T>().await?),
        Err(err) => return Err(maybe_handle_api_error(err)),
    }
}
