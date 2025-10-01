---
layout: default
title: Blog
permalink: /blog
---

<div class="page-title">
  <h1>Blog</h1>
</div>

{% assign postsByYear = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in postsByYear %}
  <div class="archive-year">{{ year.name }}</div>
  <ul class="post-list">
    {% for post in year.items %}
      <li>
        <span class="post-date">{{ post.date | date: "%b %d" }}</span>
        <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      </li>
    {% endfor %}
  </ul>
{% endfor %}