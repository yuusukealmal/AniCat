use reqwest::header::HeaderMap;

use crate::api::config::err::err_msg;

pub async fn http_get(
    url: String,
    header: Option<HeaderMap>,
    query: Option<serde_json::Value>,
) -> Result<String, String> {
    // let headers = get_headers(header.and_then(|h| h.token));
    let client = reqwest::Client::new();

    let res = client
        .get(&url)
        .headers(header.unwrap_or_default().into())
        .query(&query.unwrap_or(serde_json::Value::Null))
        .send()
        .await
        .unwrap();
    let status = res.status();
    let text = res.text().await.unwrap();

    match status {
        reqwest::StatusCode::OK => Ok(text),
        _ => Err(err_msg(&url, status.as_u16(), &format!("{}", status))),
    }
}

pub async fn http_post(url: String, body: serde_json::Value) -> Result<String, String> {
    // let headers = get_headers(header.and_then(|h| h.token));
    let client = reqwest::Client::new();

    let res = client.post(&url).json(&body).send().await.unwrap();
    let status = res.status();
    let text = res.text().await.unwrap();

    match status {
        reqwest::StatusCode::OK => Ok(text),
        _ => {
            println!("{:?}", text);
            Err(err_msg(&url, status.as_u16(), &format!("{}", text)))
        }
    }
}
