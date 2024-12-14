Map<String,String> getHeader(){
  Map<String,String> headers = {};
  headers["Accept"] = "*/*";
  headers["Accept-Language"] = 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7';
  headers["DNT"] = "1";
  headers["Sec-Fetch-Mode"] = "cors";
  headers["Sec-Fetch-Site"] = "same-origin";
  headers["cookie"] = "__cfduid=d8db8ce8747b090ff3601ac6d9d22fb951579718376; _ga=GA1.2.1940993661.1579718377; _gid=GA1.2.1806075473.1579718377; _ga=GA1.3.1940993661.1579718377; _gid=GA1.3.1806075473.1579718377";
  headers["Content-Type"] = "application/x-www-form-urlencoded";
  headers["user-agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3573.0 Safari/537.36";

  return headers;
}

Map<String,String> getHeaderCookies(){
  Map<String,String> headers = {};
  headers["Accept"] = "*/*";
  headers["Accept-Encoding"] = 'identity;q=1, *;q=0';
  headers["Accept-Language"] = 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7';
  headers["DNT"] = "1";
  headers["user-agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36';

  return headers;
}