---
title: Home
layout: default
---

<ul class="blog-posts">
{% for post in site.posts %}
    <li>
        <span>
                {{ post.date | date: "%b %d, %Y" }}
        </span>
            <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
{% endfor %}
</ul>
