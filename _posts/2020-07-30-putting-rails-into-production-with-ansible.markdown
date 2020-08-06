---
layout: post
title: "Putting Rails into production with Ansible"
date: 2020-07-30
author: Chris Schepman
show_signup: true
---

# TL;DR

I went from a hard to reproduce, hand configured server for hosting a Rails app to a nicely automated setup using Ansible. The repo is [here](https://github.com/cschep/ketten) and you can scope the README for easy to reproduce steps.

# The long version AKA Story time

**So you have this old Rails app**. You know the one. It has been dutifully doing the right thing behind the scenes since 2014. Doesn't really need any maintenance, but your friend's business.. needs it around. Doesn't depend on it, really, but like. It can't go away.

You put it on a [Linode](https://www.linode.com/?r=43da15f8d36adbbe4f26914646b1608a908abdb3) which you configured by hand and it's been working just fine.

Fast forward, now it's 2020. You've really been meaning to make an update or two. Maybe go from Rails 3 to 6? Where does the time go? How did I deploy this again?

It's time to get serious. A quick DDG for "ansible rails" turns up a contender.

# It works, until it doesn't

Major credit is due to [this](https://github.com/EmailThis/ansible-rails) repo for getting me started. It doesn't not work out of the box, which was weird, but I suppose you get what you pay for. [This](https://github.com/noahgibbs/ansible-codefolio) fork was my savior in a time of great need though. This person fixed some of the errors that I was feeling frozen about. I tend to get stuck in this mode where if code is in a repo on github somewhere, then it must be right and I must be misunderstanding it. Nothing could be further from the truth! Thank you `github.com/noahgibbs` for the great reminder that there is a fork button for a reason, and that I needed to be the arbiter of my own destiny.

# Configuration

I started by opening up `app-vars.yml` and getting to work. App name, github repo, etc. It's all pretty straightforward. Something to keep in mind is that SSL/Certbot setup requires that you already have your DNS correctly pointed at whatever new machine you're trying to deploy to. The certbot role will make real certificates. I tested using a subdomain at first, and then when it all worked I moved the real one over. Both had real certificates generated which is fine, but keep in mind Let's Encrypt will rate limit you at some point. I never had a problem with it.

# You can tell me. I’ll put it in the vault.

Provisioning the machine went fine. I had to update a dependency to a newer version to make Ubuntu 20.04 happy, but that was no problem. I had a machine with a `deployer` user that had ssh and sudo configured, good to go.

I got a little tripped up by the fact that both Ansible and Rails each have a mechanism for encrypted secrets. Rails calls them credentials, Ansible, a vault.

Since I was updating an old Rails app I hadn't encountered the new (circa 5.2) Rails credentials functionality and I wasn't sure what to put where. There is now a `master.key` which is used to encrypt/decrypt. This gets created the first time you run `rails credentials:edit`. This file has a key in it that Rails uses to encrypt/decrypt sensitive information for you. It stores the encrypted information in a file called `credentials.yml.enc`. This credentials file will be in `config/` and potentially even `config/<environment>`. You can then check in the encrypted file which keeps it all in once place. Anyone with a key can view/edit. You DO NOT check the key into your repo, but share it directly with team using something like 1Password to keep it safe. Since we're trying to automate our deployment, we need to get the contents of this file onto our server so when Rails boots up in production mode it can read the secret information and go on its merry way.

This is where Ansible's vault comes in. It's essentially the same mechanism, a key and an encrypted file you can share publicly. Using the ansible command we create a new vault e.g. `ansible-vault create group_vars/all/vault.yml` and we're off to the races. Inside of this file we put our production postgres password, and our rails master key. I was confused at first and put the `secret_key_base` as the master key. Whoops! Provide the string here that is found in the file `master.key` so that Ansible can securely pass it along when running Rails in production.

You can use the `ansible-vault` command by specifying a key file in `ansible.cfg` or by passing the flag `--ask-vault-pass`. If you use a key file DO NOT check it into source control! Same as the Rails one. Secrets abound.

# Two for the price of two

Why do we need these two mechanisms that are essentially doing the same thing and making your life more complicated? Great question! It's really just a necessary evil to gain the automated delight that is having Ansible around.

Rails needs a way to have secrets. So far so good. Ansible needs to know the secrets, but since Ansible isn't a trustworthy human we also have to protect ourselves from Ansible knowing the secrets.

I think it's worth it, but it definitely confused me at first. Up to you!

# Deploy!

Our deploy playbook uses [Ansistrano](https://ansistrano.com/) to coordinate deploys. This is a pair of Ansible playbooks that mimic the functionality of [Capistrano](https://capistranorb.com/) and do a good job of it. The name feels a little.. not perfect, but it works!

I didn't have any idea how it would find these playbooks because I hadn't installed them, but I was impressed it could figure it out. I was wrong to be impressed because it had no idea where they were. Naturally. The simple fix was to use [Ansible Galaxy](https://galaxy.ansible.com/) to install them myself. I didn't know Ansible Galaxy existed when I started this project so I actually got a bit stuck here!

`$ ansible-galaxy install ansistrano.deploy ansistrano.rollback`

Super easy, time to deploy!

# Database.yml

I followed the instructions this far and started getting database access problems. My code was there, my database config was there, what's going on?

I realized that the playbook was copying our production database config to the server, but not linking it to Rails. To fix this I added a symlink step to the `after_cleanup.yml` that Ansistrano runs after deploying.

```
- name: symlink database.yml
  file:
    src: "{{ app_shared_path }}/config/database.yml"
    dest: "{{ app_current_path }}/config/database.yml"
    owner: "{{ deploy_user }}"
    group: "{{ deploy_group }}"
    state: link
    force: yes
```

Voila! The database is off and running.

# So close

The final thing that tripped me up was that I had a `vendor` folder in my Rails root holding (you guessed it) vendored JavaScript. This problem probably doesn't exist if you are using webpacker, but the deploy playbook by default was creating a shared vendor folder for gems, and then symlinking right over the top of my already existing vendor folder. An easy fix was to just call the folder something else. I am a creative force so naturally I chose the name: `gemvendor`.

# Success

After all of this my app worked great and I was able to push up changes and re-run the deploy script just like I wanted. I could also destroy this box on Linode, grab a new one, and have a new server running my app in about 20 minutes. The initial build out takes a while because we build Ruby from scratch AND install some gems that have to build some C. Follow up deploys are fast.

I have updated the repo for my app with step by step instructions for using the updated Ansible playbooks that are contained in there. At some point I will perhaps split them into their own repo but for now I only use them in this one app so that is where they live.

Happy deploying!
