---
title: Home
layout: default
---

<ul class="ul-homepage">
{% for post in site.posts %}
    <li class="li-homepage"><a href="{{ post.url }}">{{ post.title }}</a>
    <span class="postDate">{{ post.date | date: "%b %-d %Y" }}</span><br>
    <span class="homepage-desc">{{ post.description }}</span>
    </li>
{% endfor %}
</ul>
