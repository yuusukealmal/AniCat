use reqwest::header::HeaderMap;

pub fn get_header() -> Option<HeaderMap> {
    let mut header = HeaderMap::new();

    header.insert("Accept", "*/*".parse().unwrap());
    header.insert(
        "Accept-Language",
        "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7".parse().unwrap(),
    );
    header.insert("DNT", "1".parse().unwrap());
    header.insert("Sec-Fetch-Mode", "cors".parse().unwrap());
    header.insert("Sec-Fetch-Site", "same-origin".parse().unwrap());
    header.insert(
        "cookie",
        "__cfduid=d8db8ce8747b090ff3601ac6d9d22fb951579718376; _ga=GA1.2.1940993661.1579718377; _gid=GA1.2.1806075473.1579718377; _ga=GA1.3.1940993661.1579718377; _gid=GA1.3.1806075473.1579718377".parse().unwrap(),
    );
    header.insert(
        "Content-Type",
        "application/x-www-form-urlencoded".parse().unwrap(),
    );
    header.insert(
        "user-agent",
        "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3573.0 Safari/537.36".parse().unwrap(),
    );

    Some(header)
}

pub fn get_header_cookies() -> Option<HeaderMap> {
    let mut header = HeaderMap::new();

    header.insert("Accept", "*/*".parse().unwrap());
    header.insert("Accept-Encoding", "identity;q=1, *;q=0".parse().unwrap());
    header.insert(
        "Accept-Language",
        "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7".parse().unwrap(),
    );
    header.insert("DNT", "1".parse().unwrap());
    header.insert(
        "user-agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36".parse().unwrap(),
    );

    Some(header)
}
