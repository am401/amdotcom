---
title: Add Emojis to NGINX HTTP Headers
layout: default
description: Introduce emojies into your HTTP response headers using NGINX 
---

## Written: 2020/04/29

The idea to explore adding emojis into response headers came after reading the following [Tweet by @elenalindq](https://twitter.com/elenalindq/status/1304651703904546816), specifically mentioning [icanhazip.com](https://icanhazip.com), which at the time of writing has a duck emoji HTTP response header as ween below:

```
curl -IL https://icanhazip.com
HTTP/2 200
server: nginx
date: Tue, 15 Sep 2020 03:32:56 GMT
content-type: text/plain; charset=UTF-8
content-length: 13
access-control-allow-origin: *
access-control-allow-methods: GET
x-rtfm: Learn about this site at http://bit.ly/icanhazip-faq and do not abuse the service.
x-node: icanhazip-dfw-1
x-donation: This site is expensive to run. You can donate BTC to 3LSp89k9qnMJBpV7AUNF3M2Eo1vatpkYpm
x-duck: 🦆
```

That lead me to locate other Tweets and posts about using emoji&#8217;s in NGINX headers, or HTTP headers as a whole. After some addtional digging I found that as long as the UTC-8 character set is enabled on the server, the use of emoji&#8217;s within the NGINX configuration file should work.

I eventually found an NGINX article covering the use of emoji&#8217;s within the NGINX configuration file at [Introducing Full Emoji Support in NGINX and NGINX Plus Configuration](https://www.nginx.com/blog/emoji-nginx-plus-configuration/). The article indicated copying the emoji in to the configuration file will allow it to be used in even more ways than just returning a header, such as adding them as comments within the NGINX configuration file.

I eventually found a [good list of emoji&#8217;s](https://unicode.org/emoji/charts/full-emoji-list.html#1f369) to test within the configuration file and how they would look when being viewed via cURL in this case.

```
curl -IL https://example.com
HTTP/2 200
date: Tue, 15 Sep 2020 03:49:38 GMT
content-type: text/html; charset=UTF-8
vary: Accept-Encoding
x-cacheable: SHORT
vary: Accept-Encoding,Cookie
cache-control: max-age=600, must-revalidate
x-cache: MISS
x-cache-group: normal
x-donut: : 🍩
```

So far I have tested this on Ubuntu, OSX and OpenBSD using iTerm2 without issues and using Chrome&#8217;s Dev Tools to view headers too. I was able to open the NGINX configuration file using vim and the emoji was present. Parsing the configuration file also did not return any errors!

In order to set the actual header in the configuration file the following header can be used, just change the header name and the emoji to suit your needs: 

```
add_header X-Donut: "🍩";
```

The headers are more practical in terms of providing a quirk feature as opposed to a practical functionality. Definitely an interesting concept I will continue to explore.
