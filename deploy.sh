JEKYLL_ENV=production bundle exec jekyll build; cd ansible; ansible-playbook -i inventories/production.ini deploy.yml
