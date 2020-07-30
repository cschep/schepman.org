---
layout: post
title:  "Putting Rails into production with Ansible"
date:  2020-07-30
author: Chris Schepman
show_signup: false
---

So you have this old Rails app. You know the one. It has been dutifully doing the right thing behind the scenes since 2014. Doesn't really need any maintenance, but your friend's business.. needs it around. Doesn't depend on it, really, but like. It can't go away.

You put it on a [Linode](https://www.linode.com/?r=43da15f8d36adbbe4f26914646b1608a908abdb3) which you configured by hand and it seems to work fine.

So, now it's 2020. And you've got to make an update or two. Maybe go from Rails 3 to 6?

