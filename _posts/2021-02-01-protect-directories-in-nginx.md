---
title: Protect Directories in NGINX
layout: default
description: Protect specific directories for WordPRess websites using NGINX
---

## Written: 2020/12/31

I've recently had a number of requests for custom NGINX rules to be created in order to protect WordPress upload directories. This scenario may surface if you are using NGINX as your primary web server or NGINX sits before say an upstream Apache server and the `.htaccess` files is not an option.

The following rule is specifically for static files, such as PDFs:

```nginx
if ( $uri ~* ^/wp-content/uploads/.+\.pdf$ ) {
    set $var 1;
}
    if ( $http_cookie !~* wordpress_logged_in ) {
    set $var "${var}1";
}
    if ( $var = 11 ) {
    return 403;
}
```

The above rule works by checking if the incoming request URI is looking for PDF files within `/wp-content/uploads/` and if so whether the `wordpress_logged_in` cookie is set. If it is not then return the `HTTP 403` response. Since [NGINX does not use `if/else` statements](https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/), we build out our rule using several `if` statements.
Another example we can use is the following, which uses a location block to achieve similar:

```nginx
location ~* ^/wp-content/uploads/protected/(?!public_images/).+\.jpg$ {
    add_header Cache-Control "no-store; max-age=0";
    if ( $http_cookie !~* wordpress_logged_in ) {
        return 403;
    }
}
```

The above again uses a very similar process, however this time using a `location block`. In this case, we want to protect JPG images within the `/wp-content/uploads/protected` directory, however excluding the `public_images` directory.

On top of wanting to restrict access to these files, we also want to prevent browsers and CDN providers from caching the images to prevent our condition for logged in users from being bypassed. This is achieved with setting the `Cache-Control` header, which we want irrespective of whether a `403` is returned or not.
