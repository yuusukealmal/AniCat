use flutter_rust_bridge::frb;
use select::{
    document::Document,
    predicate::{Attr, Name, Predicate},
};

use crate::api::{config::header::get_header, http::base::http_get};

pub async fn get_anime_title(url: &str) -> Result<String, String> {
    let response = http_get(url.to_string(), get_header(), None).await?;
    let document = Document::from(response.as_str());

    let title = document
        .find(Attr("class", "cat-links"))
        .last()
        .unwrap()
        .text()
        .split("分類: ")
        .last()
        .unwrap()
        .to_string();

    Ok(title)
}

#[frb(non_opaque)]
pub async fn get_anime_episode(
    url: &str,
    index: u32,
) -> Result<(bool, String, Vec<String>), String> {
    let is_last;
    let mut title = String::new();
    let mut urls = Vec::new();

    let mut url = url.to_string();
    if index > 1 {
        url.push_str(&format!("/page/{}", index));
    }
    let response = http_get(url, get_header(), None).await?;

    let document = Document::from(response.as_str());
    let h2 = document.find(Attr("class", "entry-title"));
    for element in h2 {
        if let Some(e) = element.find(Name("a").and(Attr("rel", "bookmark"))).next() {
            let url = e.attr("href").unwrap().to_string();
            urls.push(url);
        }
    }

    is_last = document
        .find(Name("div").and(Attr("class", "nav-previous")))
        .last()
        .is_none();

    if is_last {
        title = document
            .find(Attr("class", "page-title"))
            .next()
            .unwrap()
            .text()
            .to_string();
    }

    Ok((is_last, title, urls))
}
