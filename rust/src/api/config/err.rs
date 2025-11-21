pub fn err_msg(url: &str, code: u16, msg: &str) -> String {
    format!(
        "{{\"url\":\"{}\",\"code\":{},\"msg\":\"{}\"}}",
        url, code, msg
    )
}
