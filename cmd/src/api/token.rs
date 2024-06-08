use futures::Future;
use std::pin::Pin;
use std::sync::Arc;
use std::time::{Duration, SystemTime};
use tokio::sync::Mutex;
use tokio::time::sleep;

use crate::api;

pub struct AuthToken {
    token: Mutex<Option<String>>,
    expires_in: Mutex<SystemTime>,
}

impl AuthToken {
    fn new() -> Self {
        AuthToken {
            token: Mutex::new(None),
            expires_in: Mutex::new(SystemTime::now()),
        }
    }

    pub async fn get_token(&self) -> Option<String> {
        let token_lock = self.token.lock().await;
        token_lock.clone()
    }

    pub fn initialize_and_authenticate(
        attempts: u32,
    ) -> Pin<Box<dyn Future<Output = Arc<Self>> + Send>> {
        Box::pin(async move {
            let auth_token = Arc::new(AuthToken::new());

            // Simulate authentication and token retrieval
            let response = match api::login().await {
                Ok(response) => response,
                Err(err) => {
                    println!("Error during authentication: {}", err);
                    let next_backoff = Self::calculate_backoff(attempts + 1);
                    sleep(next_backoff).await;
                    return Self::initialize_and_authenticate(attempts + 1).await;
                }
            };

            let duration = Duration::from_secs(response.expires_in);

            {
                let mut token_lock = auth_token.token.lock().await;
                *token_lock = Some(response.token);

                let mut expires_lock = auth_token.expires_in.lock().await;
                *expires_lock = SystemTime::now() + duration;
            }

            println!("Authentication successful and token is set.");
            auth_token
        })
    }

    pub fn ensure_authenticated(
        self: Arc<Self>,
        attempts: u32,
    ) -> Pin<Box<dyn Future<Output = ()> + Send>> {
        Box::pin(async move {
            let expires_lock = self.expires_in.lock().await;

            if SystemTime::now() >= *expires_lock {
                println!("Token expired, renewing...");

                // Simulate token renewal
                let response = match api::login().await {
                    Ok(response) => response,
                    Err(err) => {
                        println!("Error during token renewal: {}", err);
                        let next_backoff = Self::calculate_backoff(attempts + 1);
                        sleep(next_backoff).await;
                        return Self::ensure_authenticated(self.clone(), attempts + 1).await;
                    }
                };

                let new_token = response.token;
                let duration = Duration::from_secs(response.expires_in);

                let mut token_lock = self.token.lock().await;
                let mut expires_lock = self.expires_in.lock().await;
                *token_lock = Some(new_token);
                *expires_lock = SystemTime::now() + duration;

                println!("Token renewed successfully.");
            }
        })
    }

    fn calculate_backoff(attempts: u32) -> Duration {
        let base_backoff = Duration::from_secs(1);
        base_backoff.mul_f32(2.0f32.powi(attempts as i32))
    }
}
