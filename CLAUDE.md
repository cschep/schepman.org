# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website/blog at schepman.org built with Jekyll (Ruby static site generator), deployed to GitHub Pages via GitHub Actions.

## Common Commands

- **Local dev server:** `bundle exec jekyll serve`
- **Production build:** `JEKYLL_ENV=production bundle exec jekyll build`
- **Deploy:** Push to `master` branch — GitHub Actions builds and deploys automatically
- **Install dependencies:** `bundle install`

## Architecture

- **Jekyll 4.4.1** generates static HTML into `_site/` from Markdown content and Liquid templates
- **GitHub Actions** (`.github/workflows/pages.yml`) builds and deploys on push to `master`
- **Ruby version:** 3.4.2 (mise.toml / .ruby-version)

### Key Directories

- `_posts/` — Blog posts in Markdown
- `_layouts/` — HTML templates (default, post, page, archive)
- `_includes/` — Reusable HTML partials (head, footer, analytics)
- `_plugins/` — Custom Jekyll plugins (word count stats)
- `assets/` — CSS and images

### Styling

Dark theme with CSS variables in `assets/main.css`. Monospace font, pink accent (#f74f9e). Mobile breakpoint at 600px.

### Deployment Pipeline

Push to `master` → GitHub Actions builds with Jekyll → Deploys to GitHub Pages.
