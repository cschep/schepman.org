# SCHEPMAN.ORG

This repo contains the personal website of Chris Schepman.

Want to know more? You can read about it on.. well. the personal website of [Chris Schepman.](https://schepman.org/2020/07/29/this-site) 🌝

## Deploy Notes

1. `ansible-playbook -i inventories/preprovision.ini preprovision.yml`
2. `ansible-playbook -i inventories/production.ini provision.yml`
3. `bundle exec jekyll build`
4. `ansible-playbook -i inventories/production.ini deploy.yml`
5. 🎉
