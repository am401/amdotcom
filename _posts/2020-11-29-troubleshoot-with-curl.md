---
title: Troubleshoot with cURL
layout: default
description: Techniques to use cURL when troubleshooting website connectivity issues and general cURL information
---

Written: 2020/11/29

I use [cURL](https://curl.se/) on a regular basis to troubleshoot a variety of issues both at work and while working on projects. It is an excellent tool to get an idea of what is happening when a request is made to a website. While this tool is vast in its features including connecting via `SFTP`, I will not be covering those steps within this article.

### Headers

One great feature of cURL is the ability to easily check the headers being returned from a website. In practical terms, this helps me identify the response code my request is returning. It has in the past also helped me to identify whether my request is hitting the right server and whether the right headers are being returned.

### Returning headers

To have cURL return the headers, pass the `-I` (capital i) or `--head` flags:

```
curl -I https://example.com
HTTP/2 200
date: Sun, 29 Nov 2020 03:58:17 GMT
content-type: text/html; charset=UTF-8
vary: Accept-Encoding
x-cacheable: SHORT
vary: Accept-Encoding,Cookie
cache-control: max-age=600, must-revalidate
x-cache: HIT: 2
x-cache-group: normal
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
referrer-policy: strict-origin
```

The above is the output we get from getting the headers for a site. A useful flag to include with `-I` is `-L` or `--location`, which tells `cURL` to follow `HTTP 3XX` redirects. This flag is useful when you want to ensure your request gets to the last hop in a redirect chain.

We can see this on sites where a redirect exists from the apex domain to the `www subdomain` of a site. Without the `-L` flag, the location would not be followed and the request would return a `HTTP/2 301` header, however we wouldn't be taken to a new location:

```
curl -IL https://example.com
HTTP/2 301
date: Sun, 29 Nov 2020 04:04:05 GMT
content-type: text/html
content-length: 162
location: https://www.example.com/
strict-transport-security: max-age=63072000

HTTP/2 200
date: Sun, 29 Nov 2020 04:04:06 GMT
content-type: text/html; charset=UTF-8
vary: Accept-Encoding
x-cacheable: SHORT
vary: Accept-Encoding,Cookie
cache-control: max-age=600, must-revalidate
x-cache: HIT: 3
x-cache-group: normal
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
referrer-policy: strict-origin
```

Within this set, useful flag to keep in mind is `-k` (`--insecure`) which will allow you to proceed even if an SSL connection error is detected. The output when requested a secure connect over HTTPS but hitting a certificate error looks like this:

```
curl: (60) SSL certificate problem: certificate has expired
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

As the examples above show, there is quite a lot of data there that may or may not be necessary for the task you are troubleshooting. To actually cover how I use the above here are some examples:


- Check for page redirects. I often check unexpected redirects while troubleshooting WordPress sites. Often plugins will set the `X-Redirect-By: Wordpress` header as per the [WordPress.org Developer code reference](https://developer.wordpress.org/reference/functions/wp_redirect/). Retrieving the headers can help identify the source of the loop
- Confirm that the response code is as expected
- Often hosts will set their own custom headers to identify their platform. This can help determine whether the request is hitting the right server if a recent DNS change has taken place
- When setting custom headers such as `X-Frame-Options`, `Content-Security-Policy` or other similar headers, you can confirm that these are present once set on the server
- Checking whether a page is cached or not. This may vary on the host you are checking with, but often you will see cache headers displayed

### Cookies

Cookies can be an important factor to test, whether a cookie was set or how a site reacts to receiving a specific cookie. It can be extremely useful to test cookie based cache exclusions with `cURL` by providing the request with the cookie that matches the specific rule. The two main cookie options that I use are:

- `-b` or `--cookie` which tells `cURL` to use a specific cookie.
- `-c` or `--cookie-jar` allows you to retrieve cookies either straight to standard output or to a file

Examples for the two would be:

```
curl -b 'utm_market=abc123' https://example.com
```

The above command sends the cookie named `utm_market` to the site with the content `abc123`. A use case for this  would be to set a cookie that is expected to exclude a page from cache and using the `-IL` flags see what cache headers are returned.

The other example is using the cookie-jar to save cookies received from a website:

```
Standard output:
curl -c - https://example.com -IL

Save to a file:
curl -c my_cookie_file.txt https://example.com -IL
```

The output when writing to the standard output would be as follows:

```
curl -c - https://example.com -IL
HTTP/2 200
date: Sun, 29 Nov 2020 06:00:48 GMT
content-type: text/html; charset=UTF-8
set-cookie: __cfduid=a32d321872f624290a71bdf44c5a2d8281606629648; expires=Tue, 29-Dec-20 06:00:48 GMT; path=/; domain=example.com.; HttpOnly; SameSite=Lax
vary: Accept-Encoding
x-cacheable: SHORT
set-cookie: wp_visit_time_test=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=0
vary: Accept-Encoding,Cookie
cache-control: max-age=600, must-revalidate
x-cache: HIT: 1
x-cache-group: normal
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
referrer-policy: strict-origin

# Netscape HTTP Cookie File
# https://curl.haxx.se/docs/http-cookies.html
# This file was generated by libcurl! Edit at your own risk.

HttpOnly_.example.com       TRUE    /       FALSE   1609221648      __cfduid        a32d321872f624290a71bdf44c5a2d8281606629648
example.com  FALSE   /       FALSE   1606629648      wp_visit_time_test      deleted
```

### User Agents, Referrers and IPs
Setting User Agents can sometimes help me track down my specific request within logs when troubleshooting. Setting the other elements can also help test server side rules such as rules blocking User Agents, referrers or specific IP addresses.

Setting a custom User Agent is as simple as adding the `-A` or`--user-agent` such as:

```
cURL
curl -A "My test User Agent" https://example.com

Log entry
123.123.123.123 example.com - &#91;29/Nov/2020:06:06:21 +0000] "GET / HTTP/1.0" 200 28406 "-" "My test User Agent"
```

A referrer works much the same as the User Agent by setting it with the `-e` or `--referer` (please note that the spelling is with a single <strong>r</strong>). This is again extremely useful when testing server side rules that alter the site behavior depending on referrer.:

```
cURL
curl -e "https://mysite.com" https://example.com

Log entry
123.123.123.123 example.com - &#91;29/Nov/2020:06:10:05 +0000] "GET / HTTP/1.0" 200 28406 "https://mysite.com" "curl/7.58.0"
```

You can even set the IP address your request is coming from, thus spoofing the origin of the request. Of note, for this to work you will need to ensure that the server you are requesting from has `real_ip_header X-True-client-IP;` set. By sending the header `X-True-Client-IP: [your IP]`, the server will interpret and use the value provided when handling the request. The following headers are ideal for this:

```
NGINX Server headers:

set_real_ip_from 0.0.0.0/0;
real_ip_header X-True-Client-IP;
real_ip_recursive on;

cURL
curl -IL --header "X-True-Client-IP: 12.34.56.78" https://example.com
```

The above can be useful if you are trying to determine whether an IP address is blocked by a firewall or specific server side rules affecting specific IP addresses are working as expected such as geo-location based redirects or content is being delivered as expected..

### Request Method

By default, `cURL` will use the `GET` method. By providing the `-X` flag you can change the method to different [HTTP Request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods). Sending a post request can significantly change how the server responds to your request, for example with WordPress sites, the `xmlrpc.php` file will require a `POST` method to interact with. Of note, when using the `-d` (`--data`) flag, `cURL` will automatically set the request method to `POST`. The below example is an example of a `POST` request using the data flag:

```shell
curl -d '&lt;?xml version="1.0" encoding="utf-8"?&gt;&lt;methodCall&gt;&lt;methodName&gt;system.listMethods&lt;/methodName&gt;&lt;params&gt;&lt;/params&gt;&lt;/methodCall&gt;' <a rel="noreferrer noopener" target="_blank" href="https://yoursitenameat.wpengine.com/xmlrpc.php">https://example.com/xmlrpc.php</a> -A "cURL Tutorial"
```

The data example will send a POST request with the <code>methodCall</code> to list all the available/supported methods via <code>xmlrpc.php</code> on a WordPress site.

### Authentication

There are a number of methods to authenticate, primarily using basic authentication methods. This can be done by directly supplying the `username:password` combo to the URL or using the `-u` (`--user`) option. To note, providing just the username will prompt the user to enter their password:

```
Set within the request:
curl https://testUSER:password123@example.com

or

curl -u 'testUSER:password123' https://example.com
```

A safer option than directly entering passwords and API key tokens into the shell is to use a `--netrc`. This uses the `.netrc` file in your users home directory. Alternatively using `--netrc-file` allows you to specify the file to use for authentication. The `.netrc` file uses the following format, where `machine` is the domain you are linking the authentication credentials to:

```
machine example.com
login userTEST
password qwerty123
```

An example of using the `--netrc` file to authenticate:

```
curl --netrc https://example.com
```

### Conclusion

The above is definitely not an exhaustive list, however provides some of the commands I use on a regular basis along with examples and situations I use them in. Further options and use cases can be found on the [cURL man pages](https://curl.se/docs/manpage.html).
