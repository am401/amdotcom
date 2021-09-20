---
title: Security Scanning WordPress
layout: default
description: Scan WordPress websites for security vulnerabilities using WPScan and Docker
---

## Written: 2020/04/29 // Updated: 2021/08/30
One of the best features of WordPress is that it is Open Source, allowing for the likes of you and I to modify it as we please by creating plugins or altering the look and feel by customizing themes.

This adaptability of WordPress and its thriving community is amazing, however it can occasionally lead to vulnerabilities being introduced to sites. While security issues can be found in the WordPress core files, the primary source is often through third party plugins, available on the WordPress ecosystem. [WP Scan's July 2021 Vulnerability statistics](https://blog.wpscan.com/wordpress-vulnerability-statistics-for-july-2021/) shed some light on this, highlighting that during July 2021 a total of **158 Plugin vulnerabilities** were added to their database compared to **5 Theme vulnerabilities** and no WordPress core vulnerabilities being added.

Due to WordPresses popularity, the chances of finding vulnerabilities through sites significantly increases. You will want to have some resources in your arsenal when running a WordPress site to ensure that you reduce the attack vector and are able to identify vulnerabilities. A good method for this is to run an external scan in order to see what an attacker may be able to find. This is where [WPScan](https://wpscan.com) comes into play.

This handy tool runs on the command line and can scan WordPress sites for a variety of vulnerabilities. WPScan provide a handy API which accesses their database of known vulnerabilities. An alternate resource to use would be [CVE Details' WordPress Security Vulnerabilities](https://www.cvedetails.com/product/4096/Wordpress-Wordpress.html?vendor_id=2337) database.

WPScan is a free open source security scanner, specifically designed for sites running WordPress. They have excellent [documentation](https://github.com/wpscanteam/wpscan/wiki/WPScan-User-Documentation) on the different uses and flags for the tool. This includes download instructions, however in this article I am covering specifically how to use it with [Docker](https://docker.com).

## WPScan & Docker

You can get WPScan by pulling the official image down using Docker:

```shell
docker pull wpscanteam/wpscan
```

Once downloaded, to run WPScan using Docker, you will need to call the Docker image to run. You will want to pass some arguments to WPScan though, such as the URL that you are scanning. An example would be:

```shell
docker run -it --rm wpscanteam/wpscan --url example.com
```

Breaking down the above, we call on Docker to run the **wpscanteam/wpscan** image in an interactive mode (using the **-it** flag). The **--rm** flag will remove the running image once the app has completed, cleaning up after itself.

WPScan provides a number of arguments that you can pass. Some of the more common arguments you may wish to run:
- **–url** -- Define the URL to run the scan against
- **–force** -- Force the scan, such as when the initial check suggests that the target domain is not a WordPress site
- **–enumerate u** -- Gather information on users
- **–api-token** -- Allows you to add your WPVulnDB API token in to scan the site against known vulnerabilities in the database
- **—wp-content-dir** -- Define where the URL for the wp-content directory. This is useful when the content may be served over a CDN on a custom URL

The above put together would look like this:

```shell
docker run -it --rm wpscanteam/wpscan --url example.com --api-token MYAPIKEY --force --ignore-main-redirect --enumerate u --wp-content-dir example.com/files//wp-content
```

Since we have provided an API key, WPScan will try to match affected WordPress core, theme and plugin versions to the WPScan database. If found, a warning message will be provided indicating this:

```
[+] LayerSlider
| Location: http://example.com/wp-content/plugins/LayerSlider/
|
| Found By: Urls In Homepage (Passive Detection)
|
| [!] 3 vulnerabilities identified:
|
| [!] Title: LayerSlider 4.6.1 - Style Editing CSRF
|     Fixed in: 5.2.0
|     References:
|      - https://wpscan.com/vulnerability/bb045d1d-2f23-466a-befd-35cff18f9752
|      - https://packetstormsecurity.com/files/125637/
|
| [!] Title: LayerSlider 4.6.1 - Remote Path Traversal File Access
|     Fixed in: 5.2.0
|     References:
|      - https://wpscan.com/vulnerability/b54ac5b7-aa06-4987-8473-f5116e689696
|      - https://packetstormsecurity.com/files/125637/
|
| [!] Title: LayerSlider &#60;= 6.2.0 - CSRF / Authenticated Stored XSS &#38; SQL Injection
|     Fixed in: 6.2.1
|     References:
|      - https://wpscan.com/vulnerability/9e426e65-7373-4934-89c3-42d5c1152a74
|      - http://wphutte.com/layer-slider-6-1-6-csrf-to-xss-to-sqli-with-poc/
|      - https://support.kreaturamedia.com/docs/layersliderwp/documentation.html#release-log
```

As noted in the earlier example, it's possible to pass along an API token. It's not generally good practice to be passing along API keys and passwords on the command line. Thankfully, WPScan gives us an option to save our API key in a file. The documentation specifically provides this information on using a file for the API key:

> Save API Token in a file
>
> The feature mentioned above is useful to keep the API Token in a config file and not have to supply it via the CLI each time. To do so, create the ~/.wpscan/scan.yml file containing the below:
>
> cli_options:
>
> &nbsp;&nbsp;api_token:
>
> &nbsp;&nbsp;&nbsp;YOUR_API_TOKEN
{:.blockquote-style}

It took me some experimentation to successfully link my local API YAML file to the docker container using volumes. Reading over the [WPScan dockerfile](https://hub.docker.com/r/wpscanteam/wpscan/dockerfile) I was able to descern that the docker container uses the **/wpscan** directory to deploy the app in. Using this information, I was able to link my local file to be shared within the Docker container as follows:

```shell
docker run -it --rm -v ${HOME}/.wpscan/scan.yml:/wpscan/.wpscan/scan.yml wpscanteam/wpscan --url https://example.com
```

With the above command, we are using the **-v** flag to create a volume, linking our local filesystem with the Docker container in the format of **source:destination**. This allows Docker to read the content of the file and we no longer need to pass the **--api-token** flag when running a scan.

Whether it is the database or the app itself that gets updated, it sometimes becomes necessary to update the Docker image when you start seeing this when seeing the following message:

it is easy to update the image using the Docker command:

```shell
docker pull wpscanteam/wpscan
```

This will update the image to the latest version and will resolve the update message popping up whenever you run the script.
