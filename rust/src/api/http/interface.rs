use flutter_rust_bridge::frb;
use regex::Regex;

use crate::api::http::base::http_get;
use crate::api::utils::anime_fetch::{get_anime_episode, get_anime_title};

pub async fn get_anime_list() -> Result<String, String> {
    let anime_list_url = format!(
        "https://d1zquzjgwo9yb.cloudfront.net/?_={}",
        chrono::Utc::now().timestamp()
    );

    http_get(anime_list_url, None, None).await
}

#[frb(non_opaque)]
pub async fn parse_anime_url(url: String) -> Result<(String, Vec<String>), String> {
    let mut list = Vec::new();
    let mut title = String::new();

    let esp = Regex::new(r"anime1\.me\/[0-9]").unwrap();
    let season = Regex::new(r"anime1\.me\/category\/(.*?)").unwrap();
    let cat = Regex::new(r"anime1\.me\/\?cat=\d+").unwrap();

    if esp.is_match(&url) {
        list.push(url.clone());

        if let Ok(t) = get_anime_title(&url).await {
            title = t;
        }
    } else if season.is_match(&url) || cat.is_match(&url) {
        let mut index: u32 = 1;

        while let Ok((is_last, t, mut urls)) = get_anime_episode(&url, index).await {
            println!("{} {}", index, is_last);
            list.append(&mut urls);
            if is_last {
                title = t;
                break;
            }
            index += 1;
        }
    }

    list.reverse();
    Ok((title, list))
}
