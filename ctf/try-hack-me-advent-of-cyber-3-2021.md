---
layout: default
title: TryHackMe Advent Of Cyber 3 (2021)
permalink: /ctf/try-hack-me-advent-of-cyber-3-2021/
---

{:.warning-header}
## These CTF write-ups contain spoilers

### Written: 2021/12/03

---

## Day 1 - Web Exploitation - Save The Gifts
### Challenge notes

{:.blockquote-style}
Story
The inventory management systems used to create the gifts have been tampered with to frustrate the elves. It's a night shift, and McStocker comes to McSkidy panicking about the gifts all being built wrong. With no managers around to fix the issue, McSkidy needs to somehow get access and fix the system and keep everything on track to be ready for Christmas!
Learning Objectives
* What is an IDOR vulnerability?
* How do I find and exploit IDOR vulnerabilities?
* Challenge Walkthrough.

## Day 2 - Web Exploitation - Elf HR Problems
### Challenge notes

{:.blockquote-style}
Story
McSkidy needs to check if any other employee elves have left/been affected by Grinch Industries attack, but the systems that hold the employee information have been hacked. Can you hack them back to determine if the other teams in the Best Festival Company have been affected?
Learning Objectives
* Understanding the underlying technology of web servers and how the web communicates.
* Understand what cookies are and their purpose.
* Learn how to manipulate and manage cookies for malicious use.

The aim of this exercise is to use and manipulate cookies to bypass authentication. Within this challenge we are presented with a [website](https://static-labs.tryhackme.cloud/sites/aoc-cookies/) and are asked to register an account on it. The site itself looks like this:

<img src="/assets/images/advent_of_cyber_day_2_main.png">

Using the *Sign Up* button, we are presented with a form that asks us to provide our _Name_, a _Password_ and an _Email Address_. Filling this form out and submitting the form takes us to a new page that indicates to us that registration has been disabled:

<img src="/assets/images/advent_of_cyber_day_2_registration.png">

However, using the *Google Chrome DevTools*, we can see what cookie has been set for our interaction with the site. This can be done by opening up the *DevTools* (pressing *F12* or right click within the page and click *Inspect*) and navigating to the *Applications* tab. Within the left panel, we can find the cookies that are associated with the page.

This helps us get the first answer to the challenge's questions:

<details>
<summary>Answer</summary>
<div>What is the name of the new cookie that was created for your account?
{% highlight shell %}
user-auth
{% endhighlight %}
</div>
</details> 

Inspecting the cookie value gives us the next step in the puzzle. It took me a moment to figure out what type of encoding is used. I initially ventured down on the belief that it was *Base64* but that was incorrect. I tried anumber of other encoding types to convert the string the cookie contained and eventually I found the solution.

<details>
<summary>Answer</summary>
<div>The string contained in the value:
{% highlight shell %}
7b636f6d70616e793a2022546865204265737420466573746976616c20436f6d70616e79222c206973726567697374657265643a2254727565222c20757365726e616d653a2254657374227d
{% endhighlight %}

What encoding type was used for the cookie value?
{% highlight shell %}
Hexadecimal
{% endhighlight %}</div>
</details>

In turn, decoding the string allows us to identify the answer to the next question:

<details>
<summary>Answer</summary>
<div>Decoded string:
{% highlight json %}
{company: "The Best Festival Company", isregistered:"True", username:"Test"}
{% endhighlight %}

What object format is the data of the cookie stored in?
{% highlight shell %}
json
{% endhighlight %}
</div>
</details>

Now that we've identified the cookie, decoded it and reviewed the content, we are onto the next part of this challenge. We need to manipulate the cookie in order to bypass the login. We are given a hint that the administrator's username is *admin*. In the above scenario to decode the cookie value, I was using [CyberChef](https://gchq.github.io/CyberChef), which is a great tool to easily encode/decode strings. Our next step is to alter the cookie value with our payload, encode it again and replace the existing value within our browser.

<details>
<summary>Answer</summary>
<div>String JSON value:
{% highlight json %}
{company: "The Best Festival Company", isregistered:"True", username:"admin"}
{% endhighlight %}

HEX Encoded value:
{% highlight shell %}
7b636f6d70616e793a2022546865204265737420466573746976616c20436f6d70616e79222c206973726567697374657265643a2254727565222c20757365726e616d653a2261646d696e227d
{% endhighlight %}
</div>
</details>

As mentioned, adjusting the cookie with our manipulated cookie value, we can update the browser's cookie and refresh the page. If successful, we will be taken to the *Best Festival Monitoring Dashboard*. This page also gives us the answers to the final questions:

<details>
<summary>Answer</summary>
<div><img src="/assets/images/advent_of_cyber_day_2_dashboard.png">
What team environment is not responding?
{% highlight shell %}
HR
{% endhighlight %}

What team environment has a network warning?
{% highlight shell %}
Application
{% endhighlight %}
</div>
</details>

For the most part, I was familiar with how cookies work overall and how web servers use them, but the overall refresher and guidance provided for this challenge. This definitely help explain some terms I've run into in the past, such as *SameSite*, *HttpOnly* and *Secure* when referencing cookies. These were primarily in the context of trying to set these policies on the server side when handling cookies, but I am sure they'll be useful in the long run too.

A lot of external resources also did not yield a standard for encoding cookie values. Some resources that were useful in my research:
* [HTTP Cookies Explained - Encoding](https://humanwhocodes.com/blog/2009/05/05/http-cookies-explained/#cookie-encoding)
* [Inspect the value of a cookie in JavaScript](http://www.microhowto.info/howto/inspect_the_value_of_a_cookie_in_javascript.html)
* [Encode Cookie Values](https://wiki.c2.com/?EncodeCookieValues)
* [Set-Cookie](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie) - This provides additional detail about the *Set-Cookie* HTTP header and its arguments, including the ones mentioned above, however covers encoding within cookie values.

## Day 3 - Web Exploitation - Christmas Blackout
### Challenge Notes

{:.blockquote-style}
Story
Grinch Enterprises have also tried to block communication between anyone at the company. They've locked everyone out of their email systems and McSysAdmin has also lost access to their admin panel. Can you find the admin panel and help restore communication for the Best Festival Company.
Learning Objectives
In today's task, we're going to be using our investigatory skills and techniques to discover un-listed content, and attempt some common authentication using the clues around us.

In this challenge we are introduced to [Dirbuster](https://github.com/KajanM/DirBuster), a great tool for discovering assets. In a nutshell, the tool uses wordlists to scan a target for files and paths that may exist that can be of interest to an attacker. We are also given some suggestions for wordlists that already exist on the *TryHackMe* machine that can be started up.

[SecLists](https://github.com/danielmiessler/SecLists) gives us a high number of pre-compiled wordlists. I poked around their GitHub repo to find what may be the most applicable in this case and came across *Discoery/Web-Content/Logins.fuzz.txt*. This has a number of suggested login page links that *Dirbuster* can search for.

I kick started my scan using the following command:

{% highlight shell %}
dirb http://10.10.181.131 /usr/share/wordlists/dirb/Web-Content/Logins.fuzz.txt
{% endhighlight %}

This pretty quickly returned a couple a few results, which also help answer our question:

<details>
<summary>Answer</summary>
<div>Using a common wordlist for discovering content, enumerate http://10.10.181.131 to find the location of the administrator dashboard. What is the name of the folder?
{% highlight shell %}
admin
{% endhighlight %}
</div>
</details>

Once I identified the login portal's link, I was able to interact with the login form. The information for the challenge indicates that the username is likely to be the default *administrator* and we are tasked with trying some default credentials. This then yielded the answer to the next question, allowing a successful login:

<details>
<summary>Answer</summary>
<div>In your web browser, try some default credentials on the newly discovered login form for the "administrator" user. What is the password?
{% highlight shell %}
administrator
{% endhighlight %}
</div>
</details>

The last challenge question is to find the flag on the page that we logged in to:

<details>
<summary>Flag</summary>
<div>Access the admin panel. What is the value of the flag?
{% highlight shell %}
THM{ADM1N_AC3SS}
{% endhighlight %}
</div>
</details>

I've previously used fuzzing and trying to identify web-content on sites, so this was not a topic that was completely new to me. Overall the guide was helpful in laying the groundwork on how fuzzing works and some practical experience using the machines provided by *TryHackMe* have been great as well as wordlist resources.
