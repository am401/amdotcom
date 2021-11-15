---
title: Bulk Reset WordPress Administrator Passwords
layout: default
description: Use WP CLI to bulk reset account passwords.
---

Written: 11/14/2021

Occasionally there is a need to reset a number of user passwords within WordPress. This may be due to internal policies dealing with password expiration or you are facing a security incident and you have to block that attack vector. In either scenario, there is a simple one liner that can be triggered if you have **WP CLI** and a flavor of Linux running where you have your WordPress site hosted.

{% highlight shell %}
wp user reset-password --skip-email $(wp user list --role=administrator --field=ID --format=ids | tr '\n' ' ')
{% endhighlight %}

In the above command we are using two different **WP CLI** commands. One is our primary command ([user reset-password](https://developer.wordpress.org/cli/commands/user/reset-password/)). This resets the password for one or more user from the server side. When I originaly wrote this, I found that sending an email to the user letting them know that their password was reset not only slowed down the overall command but I also ran into some errors where the email addresses were not valid and the email couldn't be sent.

The second **WP CLI** command is run in a [subshell](https://tldp.org/LDP/abs/html/subshells.html), which executes as a child process while the parent process is running. Within the subshell we are using [user list](https://developer.wordpress.org/cli/commands/user/list/), which gathers our target user list to reset the password for. In this example, we are specifying the role **adminitstaor**, therefore only users within that role will have their passwords reset, however this can either be removed or changed to a different role.

With this command we are gathering a list of account IDs and the subshell command prints them on a single line (`tr '\n' ' '`, this converts new line characters to a single space). Since the **wp user reset-password** command takes a string of account IDs, this will be automatically supplied by the subshell.

This is a quick way to force either a certain userbase (administrators) or all users to reset their passwords.
